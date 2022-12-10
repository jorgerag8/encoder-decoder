from torch import nn
from positional_encoding import PositionalEncoding


class Transformer(nn.Module):

    # input var
    def __init__(
        self,
        num_input_variables,
        dim_val,
        encoder_dim_feedforward_d_model_scalar,
        encoder_dropout,
        encoder_num_layers,
        encoder_activation,
        encoder_num_heads,
        decoder_dim_feedforward_d_model_scalar,
        decoder_dropout,
        decoder_num_layers,
        decoder_num_heads,
        decoder_activation,
        max_seq,
    ):

        super().__init__()

        self.encoder_input_layer = nn.Linear(in_features=max_seq, out_features=dim_val)

        self.positional_encoding = PositionalEncoding(dim_val, max_len=max_seq)

        # dim_feedforward must be a scalar of d_model value
        # dropout: since a larger dropout is needed within the hidden layers, ensure that it can be up to .5
        encoder_layer = nn.TransformerEncoderLayer(
            d_model=dim_val,
            nhead=encoder_num_heads,
            dim_feedforward=dim_val * encoder_dim_feedforward_d_model_scalar,
            dropout=encoder_dropout,
            activation=encoder_activation,
        )

        self.encoder = nn.TransformerEncoder(encoder_layer=encoder_layer, num_layers=encoder_num_layers)

        self.decoder_input_layer = nn.Linear(in_features=num_input_variables, out_features=dim_val)

        decoder_layer = nn.TransformerDecoderLayer(
            d_model=dim_val,
            nhead=decoder_num_heads,
            dim_feedforward=dim_val * decoder_dim_feedforward_d_model_scalar,
            dropout=decoder_dropout,
            activation=decoder_activation,
        )

        self.decoder = nn.TransformerDecoder(decoder_layer=decoder_layer, num_layers=decoder_num_layers)

        self.linear_mapping = nn.Linear(in_features=dim_val, out_features=1)

        self.sigmoid = nn.Sigmoid()

    def forward(self, source, target):
        source = self.encoder_input_layer(source)
        source = self.positional_encoding(source)
        source = self.encoder(src=source)
        target = self.decoder_input_layer(target)
        target = self.decoder(tgt=target, memory=source)
        target = self.linear_mapping(target)
        target = self.sigmoid(target)
        return target
