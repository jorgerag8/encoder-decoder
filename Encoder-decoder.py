from torch import nn
from positional_encoding import PositionalEncoding

class Encoder(nn.Module):

    #input var

    def __init__(self,num_input_variables,dim_val, dim_feedforward_encoder_d_model_scalar, encoder_dropout, num_encoder_layers):

        self.encoder_input_layer = nn.Linear(
            in_features = num_input_variables,
            out_features=dim_val)

        self.positional_encoding = PositionalEncoding(dim_val)

        #dim_feedforward must be a scalar of d_model value
        #dropout: since a larger dropout is needed within the hidden layers, ensure that it can be up to .5
        encoder_layer = nn.TransformerEncoderLayer(
            d_model=dim_val,
            nhead=8,
            dim_feedforward=dim_val*dim_feedforward_encoder_d_model_scalar,
            dropout=encoder_dropout,
            activation ='relu')

        self.encoder = nn.TransformerEncoder(
            encoder_layer=encoder_layer,
            num_layers=num_encoder_layers
        )