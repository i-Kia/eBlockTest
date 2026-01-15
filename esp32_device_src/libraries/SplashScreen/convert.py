from PIL import Image
import numpy as np

BLACK = (26, 34, 37) # 00
GRAY = (94, 103, 108) # 01
GREEN = (53, 127, 44) # 10
WHITE = (255, 255, 255) # 11

img = Image.open("splash_screen_lowres.png").convert('RGB')

pixels = np.array(img)
height, width, channels = pixels.shape

with open("SplashScreen.h", "w") as file: 
    file.write(f'''#ifndef SPLASHSCREEN_H
#define SPLASHSCREEN_H
char image[{height*width+1}] = "''')
    
    for y in range(height):
        for x in range(width):
            cur_pixel = pixels[y, x]
            if (cur_pixel == BLACK).all():
                file.write("b")
            elif (cur_pixel == GRAY).all():
                file.write("y")
            elif (cur_pixel == GREEN).all():
                file.write("g")
            elif (cur_pixel == WHITE).all():
                file.write("w")
            else:
                print(cur_pixel)
            # file.write(f"{{{pixels[y, x][0]},{pixels[y, x][1]},{pixels[y, x][2]}}},\n")
    
    file.write("\";\n#endif")