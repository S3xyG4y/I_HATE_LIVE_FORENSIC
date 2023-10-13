from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib import colors
import pandas as pd
import numpy as np
import matplotlib
import os

# 현재 작업 디렉토리를 얻습니다.
current_directory = os.getcwd()

# 하위 디렉토리 목록을 저장할 빈 리스트를 생성합니다.
subdirectories = []

# 기초 pdf파일 생성 설정
pdf_filename = 'Forensic_Report.pdf'    # pdf 파일명
doc = SimpleDocTemplate(pdf_filename, pagesize=letter) # 표 생성시 필요한 코드

story = []

# 현재 디렉토리의 모든 파일과 하위 디렉토리를 검색합니다.
for root, dirs, files in os.walk(current_directory):
    for dir in dirs:
        # 각 하위 디렉토리의 경로를 생성하고 리스트에 추가합니다.
        subdirectory_path = os.path.join(root, dir)
        subdirectories.append(subdirectory_path)
        print(subdirectory_path)

Info_path = os.path.join(current_directory, 'test', 'Forensic_Info.txt')
Info_Data = pd.read_csv(Info_path, delimiter=' : ', header=None, names=['Key', 'Value'], engine='python')
print(Info_Data)

with open(Info_path, 'r') as file:
    lines = file.readlines()[:4]
    extracted_text = ''.join(lines)

for line in lines:
    text = f"{line}"
    styles = getSampleStyleSheet()
    style = styles["Normal"]
    style.leading = 12
    p = Paragraph(text, style)
    story.append(p)
    story.append(Spacer(1, 12))

text = f"====================================================================<br/>"
styles = getSampleStyleSheet()
style = styles["Normal"]
style.leading = 12
p = Paragraph(text, style)
story.append(p)
story.append(Spacer(1, 12))

# 결과 출력
for subdir in subdirectories:
    #print(os.path.basename(subdir))
    for dir in os.listdir(subdir):
        if dir == 'Forensic_Info.txt':
            continue

        if dir.endswith('.txt'):
            txt_path = os.path.join(subdir, dir)
            filtered_rows = Info_Data[Info_Data['Key'].str.contains(dir)]
            timestamp = filtered_rows['Value'].values[0] if not filtered_rows.empty else "N/A"

            # 결과를 Paragraph로 추가
            text = f"File Name: {dir}<br/>Timestamp: {timestamp}<br/>"
            styles = getSampleStyleSheet()
            style = styles["Normal"]
            style.leading = 12
            p = Paragraph(text, style)
            story.append(p)

            # 아래에 공간 추가
            story.append(Spacer(1, 12))     

doc.build(story)

print("==============================================")

txt_path = os.path.join(current_directory, 'test')
Index_list = os.listdir(txt_path)
Original_list = Index_list
for index in Index_list:
    if index.endswith('.txt'):
        Index_list.remove(index)
# for index in Index_list:
    # print(index)
# print(len(Index_list))

print("==============================================")

# 텍스트로 출력시 필요한 코드
# txt_path = os.path.join(txt_path, 'Forensic_Info.txt')
# with open(txt_path, 'r') as file:
#     text_data = file.read()

# styles = getSampleStyleSheet()
# style = styles["Normal"]
# style.leading = 12

# text_data = text_data.replace('\n', '<br/>')

# story = []
# story.append(Paragraph(text_data, style))
# story.append(Spacer(1, 12))  # 위아래 공간 추가
# doc.build(story)
