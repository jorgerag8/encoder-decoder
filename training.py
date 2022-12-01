import torch
from torch import nn

# from torch import nn
import pandas as pd
from Transformer import Transformer

dim_val = 512
n_heads = 8
n_decoder_layers = 4
n_encoder_layers = 4
input_size = 1

trainingset = pd.DataFrame(pd.read_csv("train_data.csv"))
trainingset = trainingset.head(200)
trainingset["gcamp_lp_per_sec"] = trainingset["gcamp_lp_per_sec"].round(-3).astype("float32")
seq_len = len(trainingset)

model = Transformer(
    num_input_variables=1,
    seq_len=seq_len,
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
)
optimizer = torch.optim.SGD(model.parameters(), lr=0.05)

epochs = 10
loss_function = torch.nn.BCELoss()
m = nn.Sigmoid()

source = torch.tensor(trainingset["gcamp_lp_per_sec"].values)
target = torch.tensor(trainingset["lp_met"].values)
target = target.unsqueeze(1).type(torch.FloatTensor)

for epoch in range(epochs):

    optimizer.zero_grad()

    predicted_lp = model(source=source, target=target)
    loss = loss_function(m(predicted_lp), target)

    loss.backward()
    optimizer.step()

for i in range(0, len(predicted_lp)):
    print(m(predicted_lp[i]), target[i])

print(len(target))
