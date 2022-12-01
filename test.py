import torch
import numpy as np
import torch.nn.functional as F
from roc_auc import cal_auc
import pandas as pd
from Transformer import Transformer

dim_val = 512
n_heads = 8
n_decoder_layers = 4
n_encoder_layers = 4
input_size = 1
max_seq = 703

testset = pd.DataFrame(pd.read_csv("test_data.csv"))
testset = testset[["subject", "day", "lp_met", "gcamp_lp_per_sec"]]
# drop infs
testset = testset[~testset.isin([np.nan, np.inf, -np.inf]).any(1)]

# Get dimensions down
testset["gcamp_lp_per_sec"] = testset["gcamp_lp_per_sec"].round(-2).astype("float32")

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


def test():
    model.load_state_dict(torch.load("model.pth"))
    source = torch.tensor(testset["gcamp_lp_per_sec"][1:].values)
    source = F.pad(source, pad=(0, max_seq + 1 - len(testset)), mode="constant", value=0)
    target = torch.tensor(testset["lp_met"][1:].values)
    target = target.unsqueeze(1).type(torch.FloatTensor)
    predicted_lp = model(source=source, target=target)
    predicted = np.array([x for x in predicted_lp.detach().numpy()])
    target = np.array([str(x[0]) for x in target.detach().numpy()])
    cal_auc(target, predicted)
