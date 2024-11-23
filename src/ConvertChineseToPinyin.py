from pypinyin import pinyin, Style

def convert_to_pinyin_initials(text):
    # 将汉字转换为拼音首字母大写
    result = pinyin(text, style=Style.NORMAL)
    # 将拼音首字母大写并拼接成字符串
    pinying_text=''
    for word in result:
        pinying_text+=word[0]
    # print(pinying_text) 
    
    return pinying_text.title()

def convert_to_pinyin_capitalized(text):
    # 将每个字转换为拼音并首字母大写
    result = pinyin(text, style=Style.NORMAL)
    # 将每个拼音首字母大写并拼接成字符串
    pinyin_text = ''
    for word in result:
        pinyin_text += word[0].capitalize()
    
    return pinyin_text

print(convert_to_pinyin_initials('玛多'))
print(convert_to_pinyin_capitalized('玛多'))