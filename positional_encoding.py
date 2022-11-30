import torch
import math
import torch.nn as nn
from torch import nn, Tensor

class PositionalEncoding(nn.Module,):
    #needs to go at the bottom of the encoder and decoder stacks
    def __init__(self, d_model, max_len = 3000):
        super().__init__()

        #Hyperparameter: to introduce regularization that prevents against overfitting
        self.dropout = nn.Dropout(p=.05)

        position = torch.arange(max_len).unsqueeze(1)
        div_term = torch.exp(torch.arange(0, d_model, 2) * (-math.log(10000.0) / d_model))
        pe = torch.zeros(max_len, 1, d_model)
        pe[:, 0, 0::2] = torch.sin(position * div_term)
        pe[:, 0, 1::2] = torch.cos(position * div_term)
        self.register_buffer('pe', pe)

    def forward(self, x):
        x = x + self.pe[:, : x.size(1)].requires_grad_(False)
        return self.dropout(x)

