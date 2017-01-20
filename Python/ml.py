import numpy as np
from sklearn import datasets, linear_model
import matplotlib.pyplot as plt


def gnerate_data():

#alpha is learning rate
#reg_lambda is regularization parameter
#m is the no

def learn_linear(X, y, learning_rate, reg_prameter=0, train_percent=0.6, cv_percent=0.4, test_percent =0.4):
	alpha = learning_rate
	reg_lambda = reg_prameter
	m =1
	n = 1
	theta = generateInitialTheta(n)


def cost_linear(X, y, theta, reg_lambda):
	m = length(y)
	J_reg  = (reg_lambda / (2 * m)) * sum(thetaPrime .^ 2)

def gradient_linear(X, y)

def main():
    model = learn_logistic(X,y, learning_rate, regularization_prameter)
    ans = model.predict(x)


if __name__ == "__main__":
    main()