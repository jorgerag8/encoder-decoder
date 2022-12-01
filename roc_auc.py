# imports
import numpy as np
import pandas as pd
from sklearn import metrics
import matplotlib.pyplot as plt


def cal_auc(lp_met: np.ndarray, Scores: np.ndarray):
    fpr, tpr, thresholds = metrics.roc_curve(y_true=lp_met, y_score=Scores, pos_label='1', drop_intermediate=False)

    roc_point = pd.DataFrame({'FPR': fpr, 'TPR': tpr, 'thresholds': thresholds})
    print(roc_point)

    # print('AUC : %s'%metrics.auc(fpr,tpr))
    print('AUC: %s' % metrics.roc_auc_score(y_true=lp_met, y_score=Scores))

    fig = plt.figure(dpi=120)
    plt.plot(fpr, tpr, label='ROC curve')
    plt.plot([0, 1], [0, 1], linestyle='--')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('')
    plt.legend()
    plt.grid()

    plt.show()


lp_met = np.array(['1', '1', '0', '1', '1'])
Scores = np.array([0.9, 0.8, 0.7, 0.6, 0.55])

cal_auc(lp_met, Scores)
