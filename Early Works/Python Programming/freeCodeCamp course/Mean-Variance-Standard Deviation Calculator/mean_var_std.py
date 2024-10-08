import numpy as np

def calculate(list):
  if len(list) != 9:
    raise ValueError("List must contain nine numbers.")

  arr = np.reshape(np.array(list),(3,3))
  calculations = {}
  calculations['mean'] = [np.mean(arr, axis=0).tolist(), np.mean(arr, axis=1).tolist(),np.mean(arr.flatten()).tolist()]
  calculations['variance'] = [np.var(arr, axis=0).tolist(), np.var(arr, axis=1).tolist(),np.var(arr.flatten()).tolist()]
  calculations['standard deviation'] = [np.std(arr, axis=0).tolist(), np.std(arr, axis=1).tolist(), np.std(arr.flatten()).tolist()]
  calculations['max'] = [np.max(arr, axis=0).tolist(), np.max(arr, axis=1).tolist(), np.max(arr.flatten()).tolist()]
  calculations['min'] = [np.min(arr, axis=0).tolist(), np.min(arr, axis=1).tolist(), np.min(arr.flatten()).tolist()]
  calculations['sum'] = [np.sum(arr, axis=0).tolist(), np.sum(arr, axis=1).tolist(), np.sum(arr.flatten()).tolist()]

  return calculations
