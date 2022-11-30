import torch
# from torch import nn
import pandas as pd
from Transformer import Transformer

dim_val = 512
n_heads = 8
n_decoder_layers = 4
n_encoder_layers = 4
input_size = 1

trainingset = pd.DataFrame(pd.read_csv("train_data.csv"))
trainingset = trainingset.head(512)

model = Transformer(num_input_variables=1,
    dim_val=dim_val,
    encoder_dim_feedforward_d_model_scalar=5,
    encoder_dropout=.3,
    encoder_num_layers=n_encoder_layers,
    encoder_activation="relu",
    encoder_num_heads= n_heads,
    decoder_dim_feedforward_d_model_scalar=5,
    decoder_dropout=.3,
    decoder_num_layers=n_decoder_layers,
    decoder_num_heads= n_heads,
    decoder_activation="relu")
optimizer = torch.optim.SGD(model.parameters(), lr=.05)

epochs = 3
loss_function = torch.nn.BCELoss()

source = torch.tensor(trainingset["gcamp_lp_per_sec"].values.astype(dtype="double"))
target = torch.tensor(trainingset["lp_met"].values)

for epoch in range(epochs):

    optimizer.zero_grad()

    predicted_lp = model(source=source, target=target)
    loss = loss_function(predicted_lp, target)

    loss.backward()
    optimizer.step()

    print(model.eval())








