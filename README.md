# Detect-Chessboard-FEN

## Objective ##
Given an image, containing a 2D chessboard from the magazine _"La settimana Enigmistica"_, recognize the chessboard e build the characters string according to the FEN encoding used as standard to describe the pieces distribution inside the chessboard

![Objective](/Imgs/Objective.png)

## Approach of the algorithm ##

![Approach](/Imgs/Approach.png)

__Chessboard segmentation:__ find the black square frame of the chessboard in the image

__Projective transformation of the image:__ rectify the image and crop it around the checkerboard

__Separation of the chessboard into 64 cells:__ find inside corners of the black frame and draw horizontal and verticals lines which separate the cells

__Classification of the pieces contained in the cells:__ use a kNN classifier to recognize the cells(Bishop, Empty Square, King, etc..) and then find the pieces' colors and orientations

__Find orientation of the chessboard:__ find the global orientation from the pieces orientation and eventually rotate the chessboard; if the chessboard gets rotated go back to step _Separation of the chessboard into 64 cells_, needed for the FEN string construction and for a better analysis of the cells' contents

__Construction of the FEN string:__ build the FEN string according to the standard to describe the pieces distribution inside the chessboard

(This project is built to recognize the chessboards' images from a particular magazine, but the approach can be used for different styles of chessboards).

## Constraints ##
- Chessboard image should be taken from the magazine _"La settimana Enigmistica"_
- The chessboard has to be the biggest square object with black contour
- The checkerboard's black square frame must be completely visible
- The image shouldn't be much blurred

## Results ##
- The kNN classifier from the confusion matrix has a precision of 100% with a _Holdout_ for testing of 30%

- Of the 64 images given, the algorithm can calculate the correct FEN string, based on the respective groundtruth file ".fen", of 57 images, so with a precision of 89%. (Consider the 062 and 063 images are knowingly given to be detected wrongly because of the constraints).

- Regarding the orientation, the algorithm can correct the orientation of the chessboard with a precision of 97% (35 of 36 images)

## Errors ##
(GT stands for groundtruth)
- __004: segmentation error__ 
- __011: identification error of the color of a single piece__

        GT: 2bb1K2/4p3/5k1n/3QNP2/5R1P/8/8/8 - 0 1 FEN: 2bb1K2/4p3/5k1n/3qNP2/5R1P/8/8/8 - 0 1
        
- __020: classification error of a piece considered as an empty cell__

        GT: 4rQB1/6n1/3p4/5b2/N2R4/1P6/2k5/KR6 - 0 1 FEN: 4rQB1/6p1/3p4/5b2/3R4/1P6/2k5/KR6 - 0 1
        
- __032: orientation of the chessboard not identified correctly__
- __040: classification error of a piece considered as an empty cell__

        GT: 1B6/5p2/2pnN1P1/R1N1k3/4p3/8/5Q2/7K - 0 1 FEN: 1B6/5p2/2pnN1P1/2N1k3/4p3/8/5Q2/7K - 0 1
        
- __062: segmentation error__ (constraints not respected)
- __063: segmentation error__ (constraints not respected)

## Improvements to do ##
- The algorithm is strong with dark, variations in brightness or in perspective images but weak with blurred images
- Increase execution speed, now around 5 seconds per image
- Make more precise the segmentation of the chessboard, also in cases in which the black frame is not perfectly intact due to image conditions
- Find another method faster and more precise for identify the chessboard's orientation instead for _template matching_
- Increase the dataset to reduce the number of pieces not classified correctly
