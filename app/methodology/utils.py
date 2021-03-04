import cv2
import pandas as pd
import numpy as np
import os

def main(img_name, rgb_value):
    img_path = '../www/img/lipstick.png'
    img = cv2.imread(img_path, cv2.IMREAD_UNCHANGED)
    alpha = img[:,:,3]
    img = img[:,:,:3]
    img_lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    origin_color = cv2.cvtColor(np.array([159,65,66], dtype='uint8').reshape((1,1,3)), cv2.COLOR_RGB2LAB)
    new_color = cv2.cvtColor(np.array([rgb_value[0],rgb_value[1],rgb_value[2]], dtype='uint8').reshape((1,1,3)), cv2.COLOR_RGB2LAB)
    diff_l = new_color.flatten()[0] - origin_color.flatten()[0]
    diff_a = new_color.flatten()[1] - origin_color.flatten()[1]
    diff_b = new_color.flatten()[2] - origin_color.flatten()[2]
    for row in range(len(img_lab)):
        for col in range(len(img_lab[row])):
            if img_lab[row][col].tolist() == [0,128,128]:
                continue
            img_lab[row][col][0] += diff_l
            img_lab[row][col][1] += diff_a
            img_lab[row][col][2] += diff_b
    img_bgr = cv2.cvtColor(img_lab, cv2.COLOR_LAB2BGR)
    res = np.dstack([img_bgr, alpha])
    if not os.path.exists('../www/img/tmp'):
        os.makedirs('../www/img/tmp')
    cv2.imwrite('../www/img/tmp/' + img_name.replace(' ', '') + '.png', res)
    return img_name

if __name__ == '__main__':
    df = pd.read_excel('../www/data/sample.xlsx', sheet_name='color')
    total_color = df[
                    (df['time_period']==df['time_period'].max())&
                    (df['price_interval']=='整体')&
                    (df['age_level']=='整体')
                    ].sort_values(by='total_index', ascending=False)
    up_color = df[
                (df['time_period']==df['time_period'].max())&
                (df['price_interval']=='整体')&
                (df['age_level']=='整体')
                ].sort_values(by='up_index', ascending=False)
    all_color = pd.concat([total_color[['color_name','color_rgb']][:10],up_color[['color_name','color_rgb']][:10]]).drop_duplicates()
    for i in range(len(all_color)):
        rgb = all_color.iloc[i]['color_rgb'][1:-1].split(',')
        name = all_color.iloc[i]['color_name']
        print(rgb,name)
        main(name, rgb)
