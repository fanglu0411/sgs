# import numpy as np
#
#
#
#
#
# def random_color(number):
#     color = []
#     intnum = [str(x) for x in np.arange(10)]
#     alphabet = [chr(x) for x in (np.arange(6) + ord('A'))]
#     colorArr = np.hstack((intnum, alphabet))
#     for j in range(number):
#         color_single = '#'
#         for i in range(6):
#             index = np.random.randint(len(colorArr))
#             color_single += colorArr[index]
#         # Out[148]: '#EDAB33'
#         color.append(color_single)
#     return color
#
#
#
#
#
#
#
#
#
#
#
#
