import torch
import torch.nn as nn

class SelfAttention(nn.Module):
    def __init__(self, embed, embed_n):
        super(SelfAttention, self).__init__()
        self.embed = embed
        self.embed_n = embed_n
        self.n_dim = embed // embed_n

        assert(self.n_dim * embed_n == embed)

        self.key = nn.Linear(self.n_dim, self.n_dim, bias = False)
        self.query = nn.Linear(self.n_dim, self.n_dim, bias = False)
        self.value = nn.Linear(self.n_dim, self.n_dim, bias = False)

        self.full_connect_out = nn.Linear(embed_n * self.n_dim, embed)
    
    def foward(self, key, query, value, mask):
        N = query.shape[0]
        k_length, q_length, v_length = key.shape[1], query.shape[1], value.shape[1]
        key = key.reshape(N, k_length, self.embed_n, self.n_dim)
        query = query.reshape(N, q_length, self.embed_n, self.n_dim)
        value = value.reshape(N, v_length, self.embed_n, self.n_dim)

        #target shape: N, embed_n, q_legnth, k_legnth -> ijlm
        query_key = torch.einsum('nqhd, nkhd -> nhqk', [query, key]) 

        if mask is not None:
            query_key = query_key.masked_fill(mask == 0, float('-1e20'))

        attention = torch.softmax(query_key / (self.embed ** (1/2)), dim = 3)

        # attention shape: N, embed_n, q_legnth, k_length
        # value shape = N, v_length, embed_n, n_dim
        # target shape
        output = torch.einsum('nhql, nlhd -> nqhd', [query_key, value]).reshape(N, q_length, self.embed_n * self.n_dim)
        output = self.full_connect_out(output)
        return output
    
class TransformerLayer(nn.Module):
    def __init__(self, embed, embed_n, droput, forward_expansion):
        super(TransformerLayer, self).__init__()
        self.attention = SelfAttention(embed, embed_n)
        self.normalization_1 = nn.LayerNorm(embed)
        self.normalization_2 = nn.LayerNorm(embed)
        self.feed_forward = nn.Sequential(
            nn.Linear(embed, forward_expansion*embed),
            nn.ReLU(),
            nn.Linear(forward_expansion*embed, embed)
        )
        self.dropout = nn.Dropout(droput)
    
    def forward(self, key, query, value, mask):
        attention = self.attention(key, query, value, mask)
        
        temp = self.dropout(self.normalization_1(attention + query))
        forward = self.feed_forward(temp)
        output = self.dropout(self.normalization_2(forward + temp))
        return output
