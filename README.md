# Botmate: Vision-Guided UR3 Cobot with ArUco & MATLAB

![MATLAB](https://img.shields.io/badge/MATLAB-Computer%20Vision-0076A8?logo=mathworks&logoColor=white)
![Robot](https://img.shields.io/badge/Universal%20Robots-UR3%20Cobot-blue)
![Hardware](https://img.shields.io/badge/Raspberry%20Pi-Camera%20Module-C51A4A?logo=raspberrypi&logoColor=white)
![Topic](https://img.shields.io/badge/Robotics-Visual%20Servoing%20%26%20ArUco-success)

An academic contribution to the **Botmate** project, focused on **assistive robotics** for people with disabilities using collaborative robots (cobots). This repository implements a vision-guided pick-and-place pipeline where a **Raspberry Pi camera** detects **ArUco fiducial markers**, **MATLAB** estimates the 6-DoF marker pose, and a **Universal Robots UR3** arm moves its gripper to the target object via TCP/IP.

## How It Works

The system fuses three data streams: live camera frames, intrinsic/extrinsic camera calibration parameters, and the real-time tool center point (TCP) pose of the UR3 robot. Using **homogeneous transformation matrices**, MATLAB maps the detected ArUco marker coordinates into the robot's base frame, converts the target pose into Universal Robots' axis-angle format, and dispatches a `movep` command over TCP/IP.

```text
Raspberry Pi Camera ──► ArUco Detection ──► Marker 6-DoF Pose
                                                 + Camera-to-Gripper Calibration (Eye-in-Hand)
                                                 + Current UR3 Robot Pose
                                                 │
                                                 ▼
                                    Base Frame Transformation
                                                 │
                                                 ▼
                                Target Pose ──► movep (TCP/IP) ──► Gripper Routine
```

## Key Contributions & System Workflow

* **Computer Vision & Pose Estimation:** Integrated image acquisition from a Raspberry Pi Camera Board with ArUco marker detection and 3D pose estimation in MATLAB.
* **Kinematic Frame Transformations:** Computed and composed homogeneous transformation matrices across the marker, camera, gripper, and UR3 base coordinate frames.
* **UR3 TCP/IP Socket Communication:** Built bidirectional communication with the Universal Robots controller to read the current robot pose and send target `movep` motion commands.
* **Modular MATLAB Architecture:** Structured the control pipeline into decoupled functions for image capture, pose calculation, synchronization, and robot actuation.

## Tech Stack & Hardware

* **Software:** MATLAB, Computer Vision Toolbox
* **Hardware:** Universal Robots UR3, Raspberry Pi, Raspberry Pi Camera Board
* **Core Concepts:** ArUco Markers, 6-DoF Pose Estimation, Eye-in-Hand Calibration, Homogeneous Transformations, TCP/IP Communication, URScript (`movep`)

> *Note: Calibration parameters and motion routines were developed and tuned specifically for a **UR3** hardware setup.*

## Repository Structure

| File / Path | Description |
| :--- | :--- |
| `ejecutarGuiadoAruco.m` | Main entry point that orchestrates the complete vision-to-motion workflow. |
| `detectarAruco.m` | Captures frames and detects ArUco fiducial markers in the image. |
| `estimarPoseAruco.m` | Computes the 6-DoF marker pose and applies the camera-to-gripper transformation. |
| `recibirPoseUR3.m` | Reads the current TCP pose from the UR3 controller. |
| `iniciarProgramaUR3.m` | Initializes communication and triggers remote execution on the UR controller. |
| `moverUR3YEjecutarPrograma.m` | Sends target coordinates and executes the grasping sequence. |
| `esperarDeteccionAruco.m` | Handles synchronization and waits for valid marker detection before moving. |
| `intrinsecosCamaraRaspberry.mat` | Pre-calibrated Raspberry Pi camera intrinsic parameters loaded by the detector. |
| [Technical Guide](docs/GUIA_TECNICA.md) | Hardware setup, step-by-step execution sequence, and recalibration instructions *(in Spanish)*. |

## Scope, Requirements & Reproducibility

This repository documents the MATLAB codebase and camera intrinsic parameters used in the prototype. Reproducing the full physical setup requires:

1. A **Raspberry Pi** equipped with a Camera Module.
2. A **Universal Robots UR3** arm (or compatible UR cobot) connected over the same local network.
3. The PolyScope controller programs `test_calib_cam.urp` and `cogerpieza.urp` loaded on the UR teach pendant *(these `.urp` files were stored locally on the lab controller and are not included in this repository)*.

### Recalibration Notice
Camera intrinsics, the physical mounting offset between the camera and the gripper (eye-in-hand transform), and the physical dimensions of the printed ArUco marker directly affect pose accuracy. IP addresses and reference coordinates in the scripts belong to the original lab environment and must be recalibrated before deployment on another workstation.

> **Academic Prototype Disclaimer:** This repository is published to showcase system architecture, computer vision integration, and robot kinematics. It cannot be executed standalone without the physical hardware and PolyScope controller routines.
