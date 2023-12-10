from __future__ import print_function, division
import os
import torch
import pandas as pd
from skimage import io, transform
import numpy as np
import matplotlib.pyplot as plt
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, utils
import xml.etree.ElementTree as ET
import re

# Ignore warnings
import warnings
warnings.filterwarnings("ignore")

VALID_MODES = {"train", "test", "val"}

plt.ion()   # interactive mode

class FoodPredictionDataset(Dataset):
    """Food Prediction dataset."""

    def __init__(self, root_dir, mode="train",  transform=None):
        """
        Args:
            root_dir (string): Directory with all the images.
            mode: choose from {'train', 'test', 'val'}
            transform (callable, optional): Optional transform to be applied
                on a sample.
        """
        self.root_dir = root_dir
        self.transform = transform
        xls = pd.ExcelFile(os.path.join(self.root_dir, "density.xls"))
        self.density_df = {}
        self.sheet_names = xls.sheet_names
        self.sheet_names = [x for x in self.sheet_names if x!='mix']
        for sheet in xls.sheet_names:
          if(sheet == 'mix'):
            continue
          self.density_df[sheet] = pd.read_excel(xls, sheet)
        
        if mode not in VALID_MODES:
          raise ValueError("results: modes must be one of %r." % VALID_MODES)
        
        with open(os.path.join(self.root_dir, "ImageSets", "Main", f"{mode}.txt"), "r") as f:
          self.Images = [x.strip() for x in f.readlines() if not x.startswith('mix')]
        
    def __len__(self):
        return len(self.Images)

    def __getitem__(self, idx):
        if torch.is_tensor(idx):
            idx = idx.tolist()

        img_name = self.Images[idx]
        img_path = f"{img_name}.JPG"
        xml_path = f"{img_name}.xml"
        image = io.imread(os.path.join(self.root_dir, "JPEGImages", img_path))

        tree = ET.parse(os.path.join(self.root_dir, "Annotations", xml_path))
        root = tree.getroot()
        bndbox = tree.find('object').find('bndbox')
        landmarks =[ float(bndbox.find("xmin").text),
            float(bndbox.find("ymin").text),
            float(bndbox.find("xmax").text), 
            float(bndbox.find("ymax").text),
          ]
        fileName = os.path.join(self.root_dir, "JPEGImages",tree.find('filename').text)
        _id=tree.find('filename').text.split(".")[0]
        height=int(tree.find('size').find('height').text)
        width=int(tree.find('size').find('width').text)

        food_type = [f for f in self.sheet_names if f in img_name][0]
        splits = re.split('(\d+)', img_name)
        image_name = splits[0]+splits[1]
        category_id = self.sheet_names.index(splits[0])
        segmentation = [[]]

        index = self.density_df[food_type].index[self.density_df[food_type]['id'] == image_name]
        volume = self.density_df[food_type].iloc[index]['volume(mm^3)'].to_list()[0]
        sample = {'image': image, 'boundingBox': landmarks, 'volume': volume,'filename':fileName
        ,'image_id':_id,'height':height,'width':width,'category_id':category_id,'segmentation':segmentation}

        if self.transform:
            sample = self.transform(sample)

        return sample