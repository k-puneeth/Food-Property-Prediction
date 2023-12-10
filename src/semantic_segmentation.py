import numpy as np
import cv2
from matplotlib import pyplot as plt

class GrabCut():
    def __init__(self):
        self.bgdModel = np.zeros((1,65),np.float64)
        self.fgdModel = np.zeros((1,65),np.float64)

    def applySegmentation(self, img, bbox):
        mask = np.zeros(img.shape[:2],np.uint8)
        cv2.grabCut(img, mask, bbox, self.bgdModel, self.fgdModel, 5, cv2.GC_INIT_WITH_RECT)
        mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')
        img = img*mask2[:,:,np.newaxis]
        return mask2, img

# if __name__ == "__main__":
#     for image