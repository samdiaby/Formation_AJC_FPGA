
# setup variables to define the image dims
img_width = 64
img_height = 64

# variable to make the grid pattern
grid_width = 16

# possible colors of the grid
color1 = "0"
color2 = "255"

# boolean used to change the color of the pixel to make the grid
pixel_color = False


# generate the image directly into the
# txt file
with open("./generated_image.txt", "w+") as file:
    for y in range(img_height): # 0 to 63
        if (y != 0 and y % grid_width == 0):
            pixel_color = not pixel_color
        
        for x in range(img_width - 1): # 0 to 62 (we'll set the last pixel after the loop to avoid putting too many tabs)
            # change pixel color every grid_width pixel
            if (x % grid_width == 0):
                pixel_color = not pixel_color

            file.write(color1 if pixel_color else color2)
            # separate pixel with tabs
            file.write("\t")

        # write the last pixel of the line here to avoid
        # adding an unnecessary tab at the end of each line
        file.write(color1 if pixel_color else color2)

        # end the image line with a newline char in the txt file
        file.write("\n")
        
