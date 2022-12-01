import torch
import numpy as np
import torch.nn.functional as F

# from torch import nn
import pandas as pd
from Transformer import Transformer

dim_val = 512
n_heads = 8
n_decoder_layers = 4
n_encoder_layers = 4
input_size = 1
max_seq = 703

trainingset = pd.DataFrame(pd.read_csv("train_data.csv"))
trainingset = trainingset[["subject", "day", "lp_met", "gcamp_lp_per_sec"]]
# drop infs
trainingset = trainingset[~trainingset.isin([np.nan, np.inf, -np.inf]).any(1)]

# Get dimensions down
trainingset["gcamp_lp_per_sec"] = trainingset["gcamp_lp_per_sec"].round(-2).astype("float32")

epochs = 100
loss_function = torch.nn.BCELoss()

## Divide dataset by trials
gb = trainingset.groupby(["subject", "day"])
trials = [gb.get_group(x) for x in gb.groups]

model = Transformer(
    num_input_variables=1,
    dim_val=dim_val,
    encoder_dim_feedforward_d_model_scalar=5,
    encoder_dropout=0.1,
    encoder_num_layers=n_encoder_layers,
    encoder_activation="relu",
    encoder_num_heads=n_heads,
    decoder_dim_feedforward_d_model_scalar=5,
    decoder_dropout=0.1,
    decoder_num_layers=n_decoder_layers,
    decoder_num_heads=n_heads,
    decoder_activation="relu",
    max_seq=max_seq,
)
optimizer = torch.optim.SGD(model.parameters(), lr=0.001)

for epoch in range(epochs):

    train_loss = 0
    for trial in trials:
        source = torch.tensor(trial["gcamp_lp_per_sec"][1:].values)
        # Padding source to max lenght of sequence
        source = F.pad(source, pad=(0, max_seq + 1 - len(trial)), mode="constant", value=0)
        target = torch.tensor(trial["lp_met"][1:].values)
        target = target.unsqueeze(1).type(torch.FloatTensor)
        predicted_lp = model(source=source, target=target)
        # current_loss = loss_function(predicted_lp, target)
        # loss = loss + current_loss
        loss = loss_function(predicted_lp, target)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        train_loss += loss.item() * source.size(0)

    print(train_loss / len(trials))

for i in range(0, len(predicted_lp)):
    print(predicted_lp[i], target[i])
