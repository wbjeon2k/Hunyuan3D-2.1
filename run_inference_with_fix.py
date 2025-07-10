import os
import sys
import torch
from PIL import Image

# Add the project's sub-directory to the path to allow direct imports
sys.path.insert(0, os.path.join(os.path.abspath('.'), 'hy3dshape'))
from hy3dshape.pipelines import Hunyuan3DDiTFlowMatchingPipeline

# --- 1. Set up the paths for your trained model ---

# The training configuration file you used
CONFIG_PATH = "./hy3dshape/configs/hunyuandit-mini-overfitting-flowmatching-dinol518-bf16-lr1e4-4096.yaml"

# !!! IMPORTANT: Change this to the actual checkpoint directory you generated !!!
# This should be the path to the directory, e.g., 'ckpt-step=00002000.ckpt'
CKPT_PATH = "./hy3dshape/output_folder/dit/overfitting_depth_16_token_4096_lr1e4/ckpt/ckpt-step=00002000.ckpt"

# The input image for inference
IMAGE_PATH = "./assets/demo.png"

# The path where the final 3D model will be saved
OUTPUT_PATH = "./my_model_output.glb"


if __name__ == '__main__':
    # Setup device and data type
    if not torch.cuda.is_available():
        print("Warning: CUDA not available, running on CPU. This will be very slow.")
        device = torch.device('cpu')
        # Use float32 on CPU as it does not support bfloat16
        dtype = torch.float32
    else:
        device = torch.device('cuda')
        # Use the same precision as in training for best results
        dtype = torch.bfloat16

    print("\n--- Attempting to load the model using the new from_lightning_checkpoint method ---")

    # Load the pipeline using the new, elegant class method
    pipeline = Hunyuan3DDiTFlowMatchingPipeline.from_lightning_checkpoint(
        ckpt_path=CKPT_PATH,
        config_path=CONFIG_PATH,
        device=str(device),
        dtype=dtype,
    )

    print("\n Model loaded successfully! Starting inference...")
    input_image = Image.open(IMAGE_PATH)

    # Run inference
    mesh_output = pipeline(image=input_image)[0]

    # Save the result
    mesh_output.export(OUTPUT_PATH)
    print(f"\n Inference complete! The 3D model has been saved to: {OUTPUT_PATH}")
