function [] = edgedetection(img)

    % convert to grayscale
    L = imread(img);
    L = rgb2gray(L);
    L = double(L)/255;
    figure, imshow(L)
    
    % smoothing
    [x y] = size(L);
    Smoothed = zeros(x,y);
    
    % 5x5 Gaussian filter
    G = [2 4 5 4 2;
        4 9 12 9 4;
        5 12 15 12 5;
        4 9 12 9 4;
        2 4 5 4 2];
    G = G/159;
    
    for i = 1:x
        for j = 1:y
            Gi = 1;
            Gj = 1;
            for k = -2:2
                for l= -2:2
                    if (i+k > 0 && i+k <x && j+l > 0 && j+l < y)
                        Smoothed(i,j) = Smoothed(i,j) + (L(i+k, l+j) * G(Gi, Gj));
                    else
                        Smoothed(i,j) = Smoothed(i,j) + (L(i, j) * G(Gi, Gj));
                    end
                    Gj = Gj + 1;
                end
                Gj = 1;
                Gi = Gi + 1;
            end
            Gi = 1;
        end
    end
    figure, imshow(Smoothed)
    
    % Calculate the gradients
    GradX = zeros(x,y);
    GradY = zeros(x,y);
    Gx = [1 0 -1;
          2 0 -2;
          1 0 -1];
    Gy = [1 2 1;
          0 0 0;
          -1 -2 -1];
      
    for i = 1:x
        for j = 1:y
            Gi = 1;
            Gj = 1;
            for k = -1:1
                for l= -1:1
                    if (i+k > 0 && i+k <x && j+l > 0 && j+l < y)
                        GradX(i,j) = GradX(i,j) + (Smoothed(i+k, l+j) * Gx(Gi, Gj));
                        GradY(i,j) = GradY(i,j) + (Smoothed(i+k, l+j) * Gy(Gi, Gj));
                    else
                        GradX(i,j) = GradX(i,j) + (Smoothed(i, j) * Gx(Gi, Gj));
                        GradY(i,j) = GradY(i,j) + (Smoothed(i, j) * Gy(Gi, Gj));
                    end
                    Gj = Gj + 1;
                end
                Gj = 1;
                Gi = Gi + 1;
            end
            Gi = 1;
        end
    end
    
    % Gradient magnitude
    AbsGrad = abs(GradX) + abs(GradY);
    figure, imshow(AbsGrad)
    
    % Greadient angle
    Angles = atan2(GradY,GradX);
    Angles = Angles*180/pi;
    
    % Rounding angles
    for i=1:x
        for j=1:y
            if(Angles(i,j) < 0)
                Angles(i, j) = Angles(i, j) + 180;
            end
            if ((Angles(i,j) > 0 && Angles(i,j) < 22.5) || Angles(i,j)>157.5 && Angles(i,j) < 180)
                Angles(i,j) = 0;
            elseif (Angles(i,j) > 22.5 && Angles(i,j) < 67.5)
                Angles(i,j) = 45;
            elseif (Angles(i,j) > 67.5 && Angles(i,j) < 112.5)
                Angles(i,j) = 90;
            elseif (Angles(i,j) > 112.5 && Angles(i,j) < 157.5)
                Angles(i,j) = 135;
            end
        end
    end
    
    % non-maximum suppression
    Abs = AbsGrad;
    for i = 3:x-2
        for j=3:y-2
            if (Angles(i,j) == 0)
                if(AbsGrad(i,j-2) > AbsGrad(i,j) || AbsGrad(i,j-1) > AbsGrad(i,j) || AbsGrad(i, j+1) > AbsGrad(i,j) || AbsGrad(i, j+2) > AbsGrad(i,j))
                    Abs(i,j) = 0;
                end
            end
            if (Angles(i,j) == 90)
                if(AbsGrad(i-2,j) > AbsGrad(i,j) || AbsGrad(i-1,j) > AbsGrad(i,j) || AbsGrad(i+1, j) > AbsGrad(i,j) || AbsGrad(i+2, j) > AbsGrad(i,j))
                    Abs(i,j) = 0;
                end
            end
            if (Angles(i,j) == 45)
                if(AbsGrad(i+2,j+2) > AbsGrad(i,j) ||AbsGrad(i+1,j+1) > AbsGrad(i,j) || AbsGrad(i-1, j-1) > AbsGrad(i,j) || AbsGrad(i-2, j-2) > AbsGrad(i,j))
                    Abs(i,j) = 0;
                end
            end
            if (Angles(i,j) == 135)
                if(AbsGrad(i-2,j+2) > AbsGrad(i,j) || AbsGrad(i-1,j+1) > AbsGrad(i,j) || AbsGrad(i+1, j-1) > AbsGrad(i,j) || AbsGrad(i+2, j-2) > AbsGrad(i,j))
                    Abs(i,j) = 0;
                end
            end
        end
    end
    
    Strong =  (Abs > 0.20);
    Weak = (Abs > 0.08);
    
    for k=1:100
        for i=2:x-1
            for j=2:y-1
                if (Weak(i,j) == 1 && (Strong(i-1,j-1) ~= 0 || Strong(i-1,j) ~= 0 || Strong(i-1,j+1) ~= 0 || Strong(i,j-1) ~= 0 || Strong(i,j+1) ~= 0 || Strong(i+1,j-1) ~= 0 || Strong(i+1,j) ~= 0 || Strong(i+1,j+1) ~= 0))
                    Strong(i,j) = 1;
                end
            end
        end
    end
    figure, imshow(Strong)
end