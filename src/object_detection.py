from detectron2.engine import DefaultPredictor
from detectron2.config import get_cfg
from detectron2.utils.visualizer import Visualizer
from detectron2.data import MetadataCatalog
import cv2
import numpy as np
from detectron2 import model_zoo
from google.colab.patches import cv2_imshow
# Some basic setup:
# Setup detectron2 logger
from detectron2 import model_zoo
from detectron2.engine import DefaultPredictor
from detectron2.config import get_cfg
from detectron2.utils.visualizer import Visualizer
from detectron2.data import MetadataCatalog, DatasetCatalog
import random
import os
from detectron2.structures import BoxMode
from detectron2.engine import DefaultTrainer
from detectron2.evaluation import COCOEvaluator, inference_on_dataset
from detectron2.data import build_detection_test_loader
from detectron2.utils.visualizer import ColorMode


class ObjectDetection:

  def __init__(self):
    self.cfg = get_cfg()
    self.cfg.merge_from_file(model_zoo.get_config_file("COCO-Detection/faster_rcnn_R_50_FPN_3x.yaml"))
    self.cfg.DATASETS.TRAIN = ("food_train",)
    self.cfg.DATASETS.TEST = ()
    self.cfg.DATALOADER.NUM_WORKERS = 2
    self.cfg.MODEL.WEIGHTS = model_zoo.get_checkpoint_url("COCO-Detection/faster_rcnn_R_50_FPN_3x.yaml")
    self.cfg.SOLVER.IMS_PER_BATCH = 4  
    self.cfg.SOLVER.BASE_LR = 0.00225  
    self.cfg.SOLVER.MAX_ITER = 1500    
    self.cfg.SOLVER.STEPS = []        
    self.cfg.MODEL.ROI_HEADS.BATCH_SIZE_PER_IMAGE = 128   
    self.cfg.MODEL.ROI_HEADS.NUM_CLASSES =19
    self.predictor=None
    self.trainMetadata=None
    self.testMetadata=None
  
  def setUp(self,trainData,testData,classes):
    DatasetCatalog.register("food_train",trainData)
    DatasetCatalog.register("food_val",testData)
    self.trainMetadata = MetadataCatalog.get("food_train").set(thing_classes=classes)
    self.testMetaData = MetadataCatalog.get("food_val").set(thing_classes=classes)

  def train(self):
    os.makedirs(self.cfg.OUTPUT_DIR, exist_ok = True)
    trainer = DefaultTrainer(self.cfg)
    trainer.resume_or_load(resume=False)
    trainer.train()
    self.cfg.MODEL.WEIGHTS = os.path.join("output/", "model_final.pth") 
    self.cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.7
    self.predictor = DefaultPredictor(self.cfg)


  def evaluate(self):
    evaluator = COCOEvaluator("food_val",self.cfg,False,output_dir='./output')
    val_loader = build_detection_test_loader(self.cfg, "food_val")
    return inference_on_dataset(self.predictor.model, val_loader, evaluator) 

  def predictOnVal(self,valdata):
    for d in random.sample(valdata, len(valdata)-1):
      im = cv2.imread(d["file_name"])
      outputs = self.predictor(im)
      print(outputs)  # format is documented at https://detectron2.readthedocs.io/tutorials/models.html#model-output-format
      v = Visualizer(im[:, :, ::-1],
            metadata=self.testMetadata,
            scale=0.5,
            instance_mode=ColorMode.IMAGE  # remove the colors of unsegmented pixels. This option is only available for segmentation models
      )
      out = v.draw_instance_predictions(outputs["instances"].to("cpu"))
      cv2_imshow(out.get_image()[:, :, ::-1])


  def predict(self,image):
    pass


    

