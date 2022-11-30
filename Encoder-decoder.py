from torch import nn
from positional_encoding import PositionalEncoding

class Encoder(nn.Module):

    #input var

    def __init__(self,num_input_variables,dim_val):

        self.encoder_input_layer = nn.Linear(
            in_features = num_input_variables,
            out_features=dim_val)

        self.positional_encoding = PositionalEncoding(dim_val)

        encoder_layer = nn.TransformerEncoderLayer(
            d_model=dim_val,
            nhead=n_heads,
            dim_feedforward=dim_feedforward_encoder,
            dropout=dropout_encoder,
            batch_first=batch_first
        )