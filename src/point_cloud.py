import cv2
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import open3d as o3d


class PointCloud():
  def __init__(self, voxel_size):
      self.voxel_size = voxel_size

  def generate_point_cloud(self, depth_map, segmentation_mask):
      rows, cols = np.indices(depth_map.shape)
      points = np.column_stack((cols, rows, depth_map.flatten()))

      segmentation_labels = segmentation_mask.flatten()

      voxels = np.zeros_like(depth_map, dtype=np.uint8)

      for point, label in zip(points, segmentation_labels):
          x, y, z = point
          voxel_x, voxel_y, voxel_z = int(x / self.voxel_size), int(y / self.voxel_size), int(z / self.voxel_size)
          voxels[voxel_y, voxel_x, voxel_z] = label
      
      return voxels
  

  def merge_top_side_point_cloud(self, top_cloud, side_cloud):
      integrated_cloud = o3d.geometry.PointCloud()
      integrated_cloud.points = o3d.utility.Vector3dVector(np.vstack((top_cloud.points, side_cloud.points)))
      integrated_cloud.colors = o3d.utility.Vector3dVector(np.vstack((top_cloud.colors, side_cloud.colors)))

      return integrated_cloud

    


# Visualize the integrated point cloud
o3d.visualization.draw_geometries([integrated_cloud])


