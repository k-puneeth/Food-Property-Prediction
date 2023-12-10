import cv2
import torch

import matplotlib.pyplot as plt


model_type = "DPT_Hybrid"

class DepthEstimation():
  def __init__(self, device):
    self.midas = torch.hub.load("intel-isl/MiDaS", model_type).to(device)
    self.midas.eval()
    midas_transforms = torch.hub.load("intel-isl/MiDaS", "transforms")
    self.transform = midas_transforms.dpt_transform
    self.device = device
    
  def predict_map(self, img_batch):
    input_batch = torch.stack([self.transform(img).to(self.device) for img in img_batch])
    with torch.no_grad():
      predictions = self.midas(input_batch)

      prediction = torch.nn.functional.interpolate(
          prediction.unsqueeze(1),
          size=(img_batch[0].shape[1], img_batch[0].shape[0]),
          mode="bicubic",
          align_corners=False,
      ).squeeze()

      output = prediction.cpu().numpy()
      return output

