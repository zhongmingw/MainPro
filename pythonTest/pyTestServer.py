import urllib.request as urlReq
import chardet
import re
from bs4 import BeautifulSoup

def getHtml(url):
	request = urlReq.Request(url=url)
	response = urlReq.urlopen(request)
	html = response.read()
	charSet = chardet.detect(html)
	html = html.decode(str(charSet['encoding']))
	return html

#获取图片链接的方法
def getJpgImg(html):
    # 利用正则表达式匹配网页里的图片地址
    reg = r'src="([.*\S]*\.jpg)" pic_ext="jpeg"'
    imgre = re.compile(reg)
    imgList = re.findall(imgre,html)
    imgCount = 0
    for imgPath in imgList:
	    f = open("F:/picture/"+str(imgCount)+".jpg",'wb')
	    f.write((urlReq.urlopen(imgPath)).read())
	    f.close()
	    imgCount+=1
def getPngImg(html):
    # 利用正则表达式匹配网页里的图片地址
    reg = r'src="([.*\S]*\.png)"'
    imgre = re.compile(reg)
    imgList = re.findall(imgre,html)
    imgCount = 0
    for imgPath in imgList:
	    f = open("F:/picture/"+str(imgCount)+".png",'wb')
	    f.write((urlReq.urlopen(imgPath)).read())
	    f.close()
	    imgCount+=1
#获取新闻标题
def getNewsTitle(html):
	# 使用剖析器为html.parser
	soup = BeautifulSoup(html, 'html.parser')
	# 获取到每一个class=hot-article-img的a节点
	allList = soup.select('.hot-article-img')
	for news in allList:
		article = news.select('a')
		if len(article) > 0:
			try:
				href = url + article[0]['href']
			except Exception:
				href = ''
			try:
				imgUrl = article[0].select('img')[0]['src']
			except Exception:
				imgUrl = ""
			try:
				title = article[0]['title']
			except Exception:
				title = "标题为空"
			print("标题",title,"\nurl :",href,"\n图片地址 :",imgUrl)
			print("=============================================================================")

# url = "http://tieba.baidu.com/p/3205263090" #图片爬取测试
url = "https://www.huxiu.com" #新闻标题爬取测试
html = getHtml(url)
print(html)
f = open("F:/picture/" + "htmlTxt" + ".txt",'w',encoding="utf-8")
f.write(html)
f.close()
# getJpgImg(html)
# print("Jpg抓取完成")
# getNewsTitle(html)


# for news in allList:
#     aaa = news.select('a')
#     # 只选择长度大于0的结果
#     if len(aaa) > 0:
#         # 文章链接
#         try:#如果抛出异常就代表为空
#             href = url + aaa[0]['href']
#         except Exception:
#             href=''
#         # 文章图片url
#         try:
#             imgUrl = aaa[0].select('img')[0]['src']
#         except Exception:
#             imgUrl=""
#         # 新闻标题
#         try:
#             title = aaa[0]['title']
#         except Exception:
#             title = "标题为空"
#         print("标题",title,"\nurl：",href,"\n图片地址：",imgUrl)
#         print("==============================================================================================")

