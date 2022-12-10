import torch
import numpy as np
import torch.nn.functional as F
from sklearn.metrics import roc_auc_score


# from torch import nn
import pandas as pd
from Transformer import Transformer

dim_val = 512
n_heads = 8
n_decoder_layers = 4
n_encoder_layers = 4
input_size = 1
max_seq = 703
epochs = 100
lr = 0.0001
loss_function = torch.nn.BCELoss()

trainingset = pd.DataFrame(pd.read_csv("train_data.csv"))
testset = pd.DataFrame(pd.read_csv("test_data.csv"))
trainingset = trainingset[["subject", "day", "lp_met", "gcamp_lp_per_sec"]]
testset = testset[["subject", "day", "lp_met", "gcamp_lp_per_sec"]]
# drop infs
trainingset = trainingset[~trainingset.isin([np.nan, np.inf, -np.inf]).any(1)]
testset = testset[~testset.isin([np.nan, np.inf, -np.inf]).any(1)]

# Get dimensions down
trainingset["gcamp_lp_per_sec"] = trainingset["gcamp_lp_per_sec"].round(-2).astype("float32")
testset["gcamp_lp_per_sec"] = testset["gcamp_lp_per_sec"].round(-2).astype("float32")

## Divide dataset by trials
gb = trainingset.groupby(["subject", "day"])
trials = [gb.get_group(x) for x in gb.groups]

model = Transformer(
    num_input_variables=1,
    dim_val=dim_val,
    encoder_dim_feedforward_d_model_scalar=5,
    encoder_dropout=0.5,
    encoder_num_layers=n_encoder_layers,
    encoder_activation="relu",
    encoder_num_heads=n_heads,
    decoder_dim_feedforward_d_model_scalar=5,
    decoder_dropout=0.5,
    decoder_num_layers=n_decoder_layers,
    decoder_num_heads=n_heads,
    decoder_activation="relu",
    max_seq=max_seq,
)
optimizer = torch.optim.SGD(model.parameters(), lr=lr)

for epoch in range(epochs):

    train_loss = 0
    target_list = []
    predicted_list = []
    model.train()
    for trial in trials:
        source = torch.tensor(trial["gcamp_lp_per_sec"][1:].values)
        # Padding source to max lenght of sequence
        source = F.pad(source, pad=(0, max_seq + 1 - len(trial)), mode="constant", value=0)
        target = torch.tensor(trial["lp_met"][1:].values)
        target = target.unsqueeze(1).type(torch.FloatTensor)
        target_list = target_list + torch.squeeze(target).tolist()
        predicted_lp = model(source=source, target=target)
        predicted_list = predicted_list + torch.squeeze(predicted_lp).tolist()
        loss = loss_function(predicted_lp, target)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        train_loss += loss.item() * source.size(0)

    print("-------------------------------------")
    print("Average training Loss:", train_loss / len(trials))
    print("Training ROCAUC Score:", roc_auc_score(np.array(target_list), np.array(predicted_list)))
    ## Calculate ROCAUC testset
    model.eval()
    gb = testset.groupby(["subject", "day"])
    test_trials = [gb.get_group(x) for x in gb.groups]
    target_test_list = []
    predicted_test_list = []
    for set in test_trials:
        source_test = torch.tensor(set["gcamp_lp_per_sec"][1:].values)
        source_test = F.pad(source_test, pad=(0, max_seq + 1 - len(set)), mode="constant", value=0)
        target_test = torch.tensor(set["lp_met"][1:].values)
        target_test = target_test.unsqueeze(1).type(torch.FloatTensor)
        target_test_list = target_test_list + torch.squeeze(target_test).tolist()
        with torch.no_grad():
            predicted_test = model(source=source_test, target=target_test)
            predicted_test_list = predicted_test_list + torch.squeeze(predicted_test).tolist()
    print("Test ROCAUC Score:", roc_auc_score(np.array(target_test_list), np.array(predicted_test_list)))
