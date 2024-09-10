# #!/usr/bin/env python3
# # -*- coding: utf-8 -*-
# import numpy as np
# import pandas as pd
#
#
# # 根据列表种是否含有负数判断是pwm矩阵（含有负数）还是pfm矩阵（不含负数）
# def identify_matrix_type(p_pwm):
#     for i in p_pwm['A']:
#         if i < 0:
#             return "pwm"
#     return "pfm"
#
#
# def process_matrix(motif_view_data):
#     motif_name = motif_view_data["view_name"]
#     p_pwm = motif_view_data["view_data"]
#     pm_type = identify_matrix_type(p_pwm)
#     if pm_type == "pwm":
#         len_A = len(p_pwm['A'])
#         len_C = len(p_pwm['C'])
#         len_G = len(p_pwm['G'])
#         len_T = len(p_pwm['T'])
#         if len_A != len_C or len_C != len_G or len_G != len_T:
#             print("Inconsistent length of PWM!")
#         len_DNA = len_A
#         motif_dict_a = []
#         motif_dict_b = []
#         motif_dict_c = []
#         motif_dict_d = []
#         # 根据pwm矩阵逆计算出ppm矩阵，存入到p_base_dict_local中；
#         ppm_dict = {}
#         for i in range(len_DNA):
#             # 从pwm矩阵中取出每个位置的A，C，G，T的值
#             eA, eC, eG, eT = p_pwm['A'][i], p_pwm['C'][i], p_pwm['G'][i], p_pwm['T'][i]
#             # 根据pwm矩阵中每个位置的A，C，G，T的值反推计算出ppm矩阵中每个位置的A，C，G，T的值
#             pA, pC, pG, pT = 0.25 * np.power(2, eA), 0.25 * np.power(2, eC), 0.25 * np.power(2, eG), 0.25 * np.power(2,
#                                                                                                                      eT)
#             motif_dict_a.append(pA)
#             motif_dict_b.append(pC)
#             motif_dict_c.append(pG)
#             motif_dict_d.append(pT)
#
#         ppm_dict['A'] = motif_dict_a
#         ppm_dict['C'] = motif_dict_b
#         ppm_dict['G'] = motif_dict_c
#         ppm_dict['T'] = motif_dict_d
#
#         df_ppm_dict = pd.DataFrame(ppm_dict)
#     else:
#         df = pd.DataFrame(p_pwm)
#         total_counts = df.T.sum()
#         df_ppm_dict = (df.T / total_counts).T
#
#     return df_ppm_dict, motif_name
#
#
# # 根据数据框类型的ppm矩阵画图
# def draw_motif_logo(motif_view_data):
#     df_ppm_dict, motif_name = process_matrix(motif_view_data)
#     if df_ppm_dict.empty is False:
#         pfm = df_ppm_dict.to_dict(orient='list')
#         pfms = df_ppm_dict.fillna(0)
#         normalized_pfms = pfms.apply(lambda x: 2 + np.sum(np.log2(x ** x)), axis=1)
#         normalized_pfms_list = normalized_pfms.values.tolist()
#
#         motif_weight_list = []
#         for i in range(len(pfm['A'])):
#             n = i + 1
#             a = pfm['A'][i]
#             c = pfm['C'][i]
#             g = pfm['G'][i]
#             t = pfm['T'][i]
#             height = normalized_pfms_list[i]
#             motif_weight_list.extend(
#                 [(n, "A", a * height, "#209456"), (n, "C", c * height, "#265D9B"), (n, "G", g * height, '#FAB42C'),
#                  (n, "T", t * height, "#CE2A3C")])
#         return motif_weight_list, motif_name
#     else:
#         return 'df_ppm_dict is empty!'
#
#
# # 输入：为 pfm 矩阵或者 pwm 矩阵；
# # 输出：为每个位点的每个碱基的位置，碱基类型、高度，颜色，如下所示：
# # motif_weight_list = [(1, 'A', 0.03731678645406608, '#209456'),(1, 'C', 0.03893924072950145, '#265D9B'), (1, 'G', 0.01532964994748142, '#FAB42C'),
# # (1, 'T', 0.06208413950351874,'#CE2A3C'),(2, 'A', 0.05856249841022925, '#209456'), (2, 'C', 0.07646381083561861, '#265D9B'),
# # (2, 'G', 0.1666878568937974, '#FAB42C'),(2, 'T', 0.019130533452425255, '#CE2A3C')]
#
#
# # 测试用-pwm 矩阵
# motif_view_data = {"view_name": "1", "view_data": {
#     "A": [-0.1009, -0.5865, -2.8721, -3.4354, -3.1142, -1.2524, 0.4777, 0.4598, -2.047, -2.6542, -2.1179, 0.8225],
#     "C": [-0.0395, -0.2017, 1.2713, 1.3519, 0.93, 0.4007, 0.0244, -1.2357, -2.9739, -0.7456, 1.1366, -1.3418],
#     "G": [-1.3844, 0.9226, -1.1357, -3.4735, -1.5312, -0.1521, 0.1077, 0.7393, 1.332, 1.2271, -0.6917, -0.1653],
#     "T": [0.6335, -2.2006, -2.8721, -2.6309, 0.1863, 0.3093, -1.3893, -3.4735, -3.4735, -3.1288, -1.3358, -0.4864]}}
#
# # 测试用-pfm 矩阵
# # motif_view_data = {"view_name": "3", "view_data": {
# #     "A": [1, 10, 17, 13, 3, 7, 0, 27, 27, 27, 0, 27, 16, 7],
# #     "C": [10, 7, 4, 5, 11, 0, 0, 0, 0, 0, 25, 0, 4, 4],
# #     "G": [7, 5, 2, 5, 8, 20, 0, 0, 0, 0, 0, 0, 2, 6],
# #     "T": [9, 5, 4, 5, 0, 0, 27, 0, 0, 0, 2, 0, 5, 10]}}
#
#
# if __name__ == '__main__':
#     draw_motif_logo(motif_view_data)
