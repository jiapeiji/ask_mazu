#!/usr/bin/env python3
"""批量给 signs.json 的 #6-#30 加 i18n 字段（zh_TW + en）。"""
import json
import re

# 简→繁字形映射（覆盖签文常用字）
S2T = {
    "缘": "緣", "宾": "賓", "烛": "燭", "毕": "畢", "营": "營",
    "兹": "茲", "气": "氣", "爱": "愛",
    "风": "風", "顺": "順", "愿": "願", "马": "馬", "后": "後",
    "长": "長", "为": "為", "时": "時", "来": "來", "运": "運",
    "国": "國", "过": "過", "进": "進", "业": "業", "学": "學",
    "见": "見", "远": "遠", "听": "聽", "说": "說", "读": "讀",
    "写": "寫", "语": "語", "众": "眾", "个": "個", "会": "會",
    "体": "體", "实": "實", "习": "習", "问": "問", "决": "決",
    "报": "報", "动": "動", "发": "發", "变": "變", "门": "門",
    "间": "間", "开": "開", "关": "關", "与": "與", "应": "應",
    "当": "當", "总": "總", "万": "萬", "亿": "億", "梦": "夢",
    "圣": "聖", "庙": "廟", "妈": "媽", "灵": "靈", "归": "歸",
    "显": "顯", "龙": "龍", "凤": "鳳", "鸟": "鳥", "鱼": "魚",
    "历": "歷", "经": "經", "统": "統", "续": "續", "传": "傳",
    "护": "護", "帮": "幫", "团": "團", "苏": "蘇", "词": "詞",
    "诗": "詩", "乐": "樂", "戏": "戲", "声": "聲", "红": "紅",
    "绿": "綠", "黄": "黃", "蓝": "藍", "财": "財", "宝": "寶",
    "礼": "禮", "寿": "壽", "忧": "憂", "惧": "懼", "缓": "緩",
    "难": "難", "强": "強", "旧": "舊", "孙": "孫", "妇": "婦",
    "厅": "廳", "楼": "樓", "户": "戶", "书": "書", "画": "畫",
    "笔": "筆", "纸": "紙", "饭": "飯", "汤": "湯", "药": "藥",
    "医": "醫", "师": "師", "儿": "兒", "于": "於", "无": "無",
    "业": "業", "亲": "親", "众": "眾", "从": "從", "伤": "傷",
    "怀": "懷", "态": "態", "怜": "憐", "迟": "遲", "选": "選",
    "纵": "縱", "结": "結", "绪": "緒", "围": "圍", "园": "園",
    "图": "圖", "场": "場", "块": "塊", "复": "複", "应": "應",
    "态": "態", "怀": "懷", "怜": "憐", "侠": "俠", "俩": "倆",
    "偿": "償", "像": "像", "儿": "兒", "兑": "兌", "党": "黨",
    "兴": "興", "养": "養", "兽": "獸", "内": "內", "冈": "岡",
    "册": "冊", "军": "軍", "农": "農", "冯": "馮", "决": "決",
    "况": "況", "净": "淨", "凉": "涼", "减": "減", "凑": "湊",
    "凤": "鳳", "凭": "憑", "击": "擊", "凿": "鑿", "刘": "劉",
    "劝": "勸", "劲": "勁", "劳": "勞", "势": "勢", "勋": "勳",
    "匀": "勻", "匝": "匝", "医": "醫", "华": "華", "协": "協",
    "气": "氣", "爱": "愛", "将": "將", "头": "頭", "围": "圍",
    "卫": "衛", "厂": "廠", "厅": "廳", "历": "歷", "压": "壓",
    "厌": "厭", "厢": "廂", "厘": "釐", "县": "縣", "参": "參",
    "双": "雙", "叙": "敘", "叠": "疊", "号": "號", "叹": "嘆",
    "听": "聽", "员": "員", "呜": "嗚", "围": "圍", "图": "圖",
    "圆": "圓", "场": "場", "块": "塊", "坚": "堅", "坛": "壇",
    "坞": "塢", "坠": "墜", "墙": "牆", "垦": "墾", "墙": "牆",
    "增": "增", "坠": "墜", "声": "聲", "壳": "殼", "处": "處",
    "备": "備", "复": "複", "够": "夠", "梦": "夢", "头": "頭",
    "夸": "誇", "夹": "夾", "夺": "奪", "奋": "奮", "奖": "獎",
    "妆": "妝", "妇": "婦", "妈": "媽", "妈": "媽", "娱": "娛",
    "娴": "嫻", "婴": "嬰", "孙": "孫", "宁": "寧", "宝": "寶",
    "实": "實", "审": "審", "宪": "憲", "宫": "宮", "将": "將",
    "尊": "尊", "导": "導", "岁": "歲", "岛": "島", "崭": "嶄",
    "巩": "鞏", "帅": "帥", "师": "師", "师": "師", "帐": "帳",
    "帘": "簾", "帜": "幟", "帮": "幫", "带": "帶", "帧": "幀",
    "广": "廣", "庄": "莊", "庆": "慶", "庐": "廬", "库": "庫",
    "应": "應", "庙": "廟", "庞": "龐", "废": "廢", "广": "廣",
    "异": "異", "弃": "棄", "张": "張", "弦": "弦", "弹": "彈",
    "强": "強", "归": "歸", "当": "當", "录": "錄", "彻": "徹",
    "径": "徑", "从": "從", "态": "態", "怀": "懷", "怜": "憐",
    "恼": "惱", "恨": "恨", "恼": "惱", "悦": "悅", "悬": "懸",
    "惊": "驚", "惧": "懼", "惨": "慘", "惯": "慣", "恼": "惱",
    "惩": "懲", "怀": "懷", "懒": "懶", "憾": "憾", "怀": "懷",
    "战": "戰", "户": "戶", "扑": "撲", "打": "打", "扔": "扔",
    "托": "託", "执": "執", "扩": "擴", "扬": "揚", "抚": "撫",
    "扰": "擾", "报": "報", "担": "擔", "拟": "擬", "拥": "擁",
    "拨": "撥", "择": "擇", "挡": "擋", "挣": "掙", "挽": "挽",
    "换": "換", "据": "據", "掷": "擲", "损": "損", "掺": "摻",
    "搀": "攙", "搁": "擱", "搂": "摟", "搅": "攪", "摊": "攤",
    "撑": "撐", "撒": "撒", "撞": "撞", "播": "播", "抚": "撫",
    "击": "擊", "揽": "攬", "收": "收", "改": "改", "攻": "攻",
    "敌": "敵", "数": "數", "斗": "鬥", "断": "斷", "旧": "舊",
    "无": "無", "时": "時", "旷": "曠", "明": "明", "昏": "昏",
    "易": "易", "晕": "暈", "暗": "暗", "显": "顯", "晕": "暈",
    "晋": "晉", "晒": "曬", "晕": "暈", "景": "景", "晰": "晰",
    "暖": "暖", "暗": "暗", "暮": "暮", "暴": "暴", "曙": "曙",
    "暴": "暴", "曲": "曲", "更": "更", "曾": "曾", "替": "替",
    "最": "最", "会": "會", "月": "月", "有": "有", "服": "服",
    "望": "望", "朝": "朝", "期": "期", "木": "木", "未": "未",
    "末": "末", "本": "本", "机": "機", "杀": "殺", "权": "權",
    "杆": "桿", "极": "極", "杨": "楊", "构": "構", "枞": "樅",
    "标": "標", "栈": "棧", "栋": "棟", "栏": "欄", "树": "樹",
    "栖": "棲", "样": "樣", "核": "核", "根": "根", "格": "格",
    "栽": "栽", "桥": "橋", "梁": "梁", "梦": "夢", "检": "檢",
    "楼": "樓", "概": "概", "槟": "檳", "横": "橫", "樱": "櫻",
    "权": "權", "欢": "歡", "欤": "歟", "欧": "歐", "欲": "欲",
    "歌": "歌", "欢": "歡", "止": "止", "正": "正", "此": "此",
    "步": "步", "武": "武", "岁": "歲", "历": "歷", "归": "歸",
    "死": "死", "残": "殘", "段": "段", "殷": "殷", "殿": "殿",
    "毁": "毀", "毅": "毅", "母": "母", "每": "每", "比": "比",
    "毕": "畢", "毛": "毛", "毫": "毫", "气": "氣", "永": "永",
    "求": "求", "汇": "匯", "汉": "漢", "汤": "湯", "汹": "洶",
    "没": "沒", "泪": "淚", "泻": "瀉", "注": "注", "泽": "澤",
    "泾": "涇", "洁": "潔", "洒": "灑", "济": "濟", "浆": "漿",
    "浏": "瀏", "浑": "渾", "浓": "濃", "济": "濟", "浆": "漿",
    "润": "潤", "涨": "漲", "涩": "澀", "渐": "漸", "渔": "漁",
    "渡": "渡", "温": "溫", "游": "遊", "湾": "灣", "湿": "濕",
    "溃": "潰", "满": "滿", "滥": "濫", "潇": "瀟", "潜": "潛",
    "潭": "潭", "潮": "潮", "激": "激", "濒": "瀕", "灭": "滅",
    "灯": "燈", "炉": "爐", "点": "點", "烈": "烈", "烟": "煙",
    "烦": "煩", "热": "熱", "焕": "煥", "煌": "煌", "熟": "熟",
    "燃": "燃", "爱": "愛", "爷": "爺", "牵": "牽", "特": "特",
    "犹": "猶", "狈": "狽", "猎": "獵", "猫": "貓", "献": "獻",
    "猪": "豬", "玛": "瑪", "环": "環", "现": "現", "玛": "瑪",
    "珐": "琺", "珠": "珠", "球": "球", "理": "理", "琼": "瓊",
    "瑞": "瑞", "璃": "璃", "瓦": "瓦", "画": "畫", "画": "畫",
    "畅": "暢", "疯": "瘋", "疲": "疲", "疾": "疾", "症": "症",
    "痪": "瘓", "痴": "癡", "瘟": "瘟", "癣": "癬", "皇": "皇",
    "盖": "蓋", "盗": "盜", "盘": "盤", "盛": "盛", "监": "監",
    "盾": "盾", "眠": "眠", "睡": "睡", "睦": "睦", "瞒": "瞞",
    "矛": "矛", "码": "碼", "碍": "礙", "碑": "碑", "碟": "碟",
    "磁": "磁", "示": "示", "社": "社", "祠": "祠", "票": "票",
    "祭": "祭", "祸": "禍", "禅": "禪", "福": "福", "离": "離",
    "种": "種", "积": "積", "称": "稱", "稳": "穩", "穷": "窮",
    "签": "籤", "简": "簡", "箫": "簫", "简": "簡", "简": "簡",
    "篮": "籃", "篱": "籬", "簿": "簿", "类": "類", "粉": "粉",
    "粒": "粒", "粹": "粹", "糊": "糊", "糟": "糟", "系": "系",
    "紧": "緊", "索": "索", "紫": "紫", "繁": "繁", "红": "紅",
    "约": "約", "级": "級", "纪": "紀", "纲": "綱", "纳": "納",
    "纵": "縱", "纶": "綸", "纷": "紛", "纸": "紙", "纹": "紋",
    "线": "線", "组": "組", "细": "細", "终": "終", "绊": "絆",
    "绍": "紹", "经": "經", "结": "結", "绕": "繞", "绣": "繡",
    "继": "繼", "续": "續", "绳": "繩", "维": "維", "综": "綜",
    "绿": "綠", "缅": "緬", "缠": "纏", "缩": "縮", "缸": "缸",
    "缺": "缺", "罢": "罷", "罪": "罪", "置": "置", "署": "署",
    "群": "群", "羡": "羨", "义": "義", "习": "習", "翘": "翹",
    "翻": "翻", "老": "老", "考": "考", "耐": "耐", "联": "聯",
    "聪": "聰", "肃": "肅", "肢": "肢", "肤": "膚", "肿": "腫",
    "胁": "脅", "胆": "膽", "胎": "胎", "胜": "勝", "胞": "胞",
    "脂": "脂", "脏": "臟", "脆": "脆", "脑": "腦", "脓": "膿",
    "脱": "脫", "脸": "臉", "腊": "臘", "腋": "腋", "腌": "醃",
    "腐": "腐", "腻": "膩", "膀": "膀", "膊": "膊", "膛": "膛",
    "膨": "膨", "臂": "臂", "臼": "臼", "舆": "輿", "舍": "舍",
    "舒": "舒", "舰": "艦", "艰": "艱", "芜": "蕪", "芦": "蘆",
    "苏": "蘇", "苗": "苗", "苹": "蘋", "茎": "莖", "茔": "塋",
    "荆": "荊", "荐": "薦", "荚": "莢", "荞": "蕎", "荟": "薈",
    "荠": "薺", "荧": "熒", "荫": "蔭", "药": "藥", "荷": "荷",
    "莅": "蒞", "获": "獲", "莱": "萊", "莲": "蓮", "莴": "萵",
    "莹": "瑩", "莺": "鶯", "萝": "蘿", "萧": "蕭", "萨": "薩",
    "虚": "虛", "虫": "蟲", "虹": "虹", "虾": "蝦", "蚂": "螞",
    "蚊": "蚊", "蚕": "蠶", "蛇": "蛇", "蛋": "蛋", "蛛": "蛛",
    "蛮": "蠻", "蜘": "蜘", "蝉": "蟬", "蝇": "蠅", "螃": "螃",
    "螫": "螫", "蟹": "蟹", "衫": "衫", "衬": "襯", "衮": "袞",
    "衰": "衰", "衷": "衷", "袂": "袂", "袖": "袖", "袜": "襪",
    "装": "裝", "裆": "襠", "裤": "褲", "褛": "褸", "褴": "襤",
    "复": "複", "览": "覽", "观": "觀", "规": "規", "视": "視",
    "觊": "覬", "览": "覽", "观": "觀", "觉": "覺", "觊": "覬",
    "觐": "覲", "觑": "覷", "觞": "觴", "觥": "觥", "觊": "覬",
    "觏": "覯", "觐": "覲", "觑": "覷", "言": "言", "讦": "訐",
    "讥": "譏", "讦": "訐", "讧": "訌", "讨": "討", "讪": "訕",
    "讫": "訖", "讬": "託", "训": "訓", "讹": "訛", "论": "論",
    "讻": "訩", "讼": "訟", "讽": "諷", "访": "訪", "设": "設",
    "诀": "訣", "证": "證", "诂": "詁", "评": "評", "诅": "詛",
    "识": "識", "诃": "訶", "诉": "訴", "诊": "診", "诚": "誠",
    "词": "詞", "诞": "誕", "诟": "詬", "诡": "詭", "询": "詢",
    "诣": "詣", "该": "該", "详": "詳", "诧": "詫", "诩": "詡",
    "诫": "誡", "诬": "誣", "语": "語", "诮": "誚", "误": "誤",
    "诰": "誥", "诱": "誘", "诲": "誨", "诳": "誑", "说": "說",
    "诵": "誦", "请": "請", "诸": "諸", "诹": "諏", "诺": "諾",
    "读": "讀", "诼": "諑", "诽": "誹", "课": "課", "诿": "諉",
    "调": "調", "谀": "諛", "谁": "誰", "论": "論", "谂": "諗",
    "调": "調", "谄": "諂", "谅": "諒", "谆": "諄", "谇": "誶",
    "谈": "談", "谊": "誼", "谋": "謀", "谓": "謂", "谍": "諜",
    "谎": "謊", "谐": "諧", "谑": "謔", "谒": "謁", "谔": "諤",
    "谕": "諭", "谖": "諼", "谗": "讒", "谘": "諮", "谙": "諳",
    "谚": "諺", "谛": "諦", "谜": "謎", "谝": "諞", "谟": "謨",
    "谠": "讜", "谡": "謁", "谢": "謝", "谣": "謠", "谤": "謗",
    "谥": "謚", "谦": "謙", "谧": "謐", "谨": "謹", "谩": "謾",
    "谪": "謫", "谫": "譾", "谬": "謬", "谭": "譚", "谮": "譖",
    "谯": "譙", "谰": "譫", "谲": "譎", "谳": "讞", "谵": "譫",
    "谶": "讖", "谷": "穀", "豮": "豮", "贝": "貝", "贞": "貞",
    "负": "負", "财": "財", "贡": "貢", "贫": "貧", "贬": "貶",
    "贮": "貯", "贱": "賤", "贵": "貴", "贺": "賀", "贻": "貽",
    "贼": "賊", "贾": "賈", "贿": "賄", "赁": "賃", "赂": "賂",
    "债": "債", "值": "值", "倾": "傾", "假": "假", "偌": "偌",
    "偎": "偎", "偏": "偏", "做": "做", "停": "停", "健": "健",
    "偶": "偶", "偷": "偷", "偿": "償", "偶": "偶", "偷": "偷",
    "偻": "僂", "偾": "僨", "偿": "償", "侧": "側", "侦": "偵",
    "伪": "偽", "倦": "倦", "俨": "儼", "俩": "倆", "俪": "儷",
    "俟": "俟", "俎": "俎", "俨": "儼", "俪": "儷", "俭": "儉",
    "俦": "儔", "俨": "儼", "俟": "俟", "俐": "俐", "俣": "俁",
    "俦": "儔", "俨": "儼", "俩": "倆", "俾": "俾", "俯": "俯",
    "侔": "侔", "俦": "儔", "俨": "儼", "倔": "倔", "倨": "倨",
    "倩": "倩", "倪": "倪", "倭": "倭", "偃": "偃", "偕": "偕",
    "偈": "偈", "偎": "偎", "偻": "僂", "偲": "偲", "偶": "偶",
    "偷": "偷", "偻": "僂", "偿": "償", "侧": "側", "侦": "偵",
    "伪": "偽", "俭": "儉", "俦": "儔", "俨": "儼", "俩": "倆",
    "俪": "儷", "俟": "俟", "俎": "俎", "俨": "儼", "俪": "儷",
    "俭": "儉", "俦": "儔", "俨": "儼", "俟": "俟", "俐": "俐",
    "俣": "俁", "俦": "儔", "俨": "儼", "俩": "倆", "俾": "俾",
    "俯": "俯", "侔": "侔", "俦": "儔", "俨": "儼", "倔": "倔",
    "倨": "倨", "倩": "倩", "倪": "倪", "倭": "倭", "偃": "偃",
    "偕": "偕", "偈": "偈", "偎": "偎", "偻": "僂", "偲": "偲",
    "做": "做", "停": "停", "健": "健", "偶": "偶", "偷": "偷",
    "偿": "償",
}

# 加载现有 signs.json
with open('assets/data/signs.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 翻译数据（#6-#30）
translations = {
    6: {
        "title": "Wealth Flows In",
        "poem": "The wealth-star shines bright, fortune flows freely. Streams from afar grow day by day. Prosperity gathers from the four quarters, profit earned thanks to Heaven above.",
        "interpretation": "Great fortune in wealth. For those seeking money, gains come. For those in business, profits accrue. For job seekers, a high salary. For investors, honest gain.",
        "allusion": "Mazu temples often bear the name Tongyuan (Reaching Far). The ancestral temple on Meizhou Island in Putian, Fujian, the Fotangmen temple in Hong Kong, and Beigang Chaotian Gong — all carry this name, symbolizing Mazu's protection of merchants and seafarers.",
        "modernNotes": ["Investment: profitable", "Business: gains", "Job: high salary", "Side hustle: viable"]
    },
    7: {
        "title": "Family at Peace",
        "poem": "Old and young gather in harmony, the two words \"peace\" are worth a thousand. The kind mother waits by the door, the wanderer returns to gladness.",
        "interpretation": "Great fortune in family. Marriage: harmony. Loved ones: safe. Those far from home: return is near. Family members: all well.",
        "allusion": "Mazu is also called Guma or Niangma — the seaside people's protector on the sea, and the household's protector too. On the first and fifteenth of each month, devotees burn incense at Mazu temples, praying for their family's safety.",
        "modernNotes": ["Marriage: harmonious", "Family: safe", "Reunion: likely", "Children: filial"]
    },
    8: {
        "title": "All Things as You Wish",
        "poem": "All things go as the heart desires; what comes, fits the mind. Twelve hours of the day bring fortune — why ask again for gain or fame?",
        "interpretation": "Today, all matters go smoothly. Step out and meet a noble one. Ask, and you shall receive. But do not grow proud; keep a kind heart.",
        "allusion": "On the day of Mazu's ascension (the 9th day of the 9th lunar month), coastal communities hold grand ceremonies, praying that the year brings all things as wished.",
        "modernNotes": ["Today: smooth", "Job search: success", "Negotiation: favorable", "Investment: small gain"]
    },
    9: {
        "title": "Sea and Sky, Long Life",
        "poem": "The sea holds a hundred rivers, vast in its breadth. Heaven and earth endure, long life and health. Fortune deep as the Eastern Sea, longevity high as Southern Mountain.",
        "interpretation": "Great fortune in health, a sign of long life. For the sick, this sign brings reassurance of recovery. For the elderly, peace and well-being.",
        "allusion": "Mazu, born in 960 with the family name Lin, is said to have ascended at 28. Yet her spirit endures, protecting all beings for a thousand years. Coastal people see Mazu as a symbol of long life.",
        "modernNotes": ["Illness: recovery with treatment", "Elders: peace and health", "Self: watch diet and rest, long-term improvement"]
    },
    10: {
        "title": "Purple Aura from the East",
        "poem": "Purple aura comes from the east, ten thousand things renewed. A ray of holy light shines on the dust of the road. A noble one aids in secret, the road ahead is long. May the venture flourish, thanks to Mazu.",
        "interpretation": "Career with noble help. Promotion: success. Startup: assistance comes. But stay humble; do not boast.",
        "allusion": "Laozi rode his ox westward; the purple aura came from the east for thirty thousand miles. Purple aura is a sign of auspiciousness.",
        "modernNotes": ["Promotion: success", "Startup: help comes", "Negotiation: favorable", "Job transfer: smooth"]
    },
    11: {
        "title": "Phoenix in Harmony",
        "poem": "Phoenix and phoenix sing in flight, paired wings. A hundred years of harmony shared in the slanting sun. The good match was fated in a former life, hand in hand unto old age, never parting.",
        "interpretation": "Great fortune in love. Proposal: success. Dating: union. Reconciliation: a return to harmony.",
        "allusion": "The Book of Songs records: the phoenix takes flight, its wings whirring — a metaphor for marital harmony.",
        "modernNotes": ["Proposal: success", "Dating: union", "Reconciliation: return to harmony", "Marriage: bliss"]
    },
    12: {
        "title": "Calling Wealth, Gathering Treasure",
        "poem": "Wealth's qi enters the door, the treasure basin overflows with a hundred gems. Through four seasons wealth flows in, dressed and fed, joy and peace rise.",
        "interpretation": "Upper-middle fortune in wealth. For those seeking money, gains come. For those in business, profit. But act with integrity; avoid side doors.",
        "allusion": "Mazu temples often have oil donation boxes. Devotees donate oil to feed the temple lamps, symbolizing added wealth.",
        "modernNotes": ["Investment: small gain", "Business: profit", "Side hustle: viable", "Easy money: not to be forced"]
    },
    13: {
        "title": "A Rooster's Flight of Ten Thousand Miles",
        "poem": "The great rooster spreads its wings to the ninth heaven, its aim is a journey of a thousand miles. Beating pinions, soaring above the highest peak, whirling upward to the heavenly court.",
        "interpretation": "Career achievement, far-reaching prospects. Job seekers: high position. Promotion: steady advancement.",
        "allusion": "Zhuangzi's \"Free and Easy Wandering\" records: when the rooster migrates to the southern sea, it strikes the water three thousand miles, and spiraling upward rises ninety thousand miles.",
        "modernNotes": ["Job search: high position", "Promotion: smooth", "Startup: bright prospects", "Study abroad: offer comes"]
    },
    14: {
        "title": "Flower Opens, Buddha Appears",
        "poem": "One flower, one world. One leaf, one bodhi. Today, the heart is clear — the Buddha appears in an instant.",
        "interpretation": "Today, the heart is at peace, and all is well. Stay quiet and steady; do not rush.",
        "allusion": "In Zen, there is the tale of the silent flower. Shakyamuni held up a flower before the assembly; only Mahakashyapa broke into a smile.",
        "modernNotes": ["Today: peaceful", "Worries: let go", "Work: steady", "Decisions: wait for the right moment"]
    },
    15: {
        "title": "Full Moon, Blooming Flowers",
        "poem": "The moon at the fifteenth shines brighter than usual, flowers bloom filling the garden with spring. Treasure this fine night, this beautiful scene — do not betray the heart of a precious bond.",
        "interpretation": "Good fortune in love. Marriage: harmony. Dating: hearts aligned. Cherish those before you.",
        "allusion": "Su Shi's words: may we live long, sharing this beautiful moon even across a thousand miles.",
        "modernNotes": ["Marriage: harmonious", "Dating: hearts aligned", "Family: reunion", "Friendship: lasting"]
    },
    16: {
        "title": "Name on the Golden List",
        "poem": "Ten years at the cold window, books in hand. One morning the golden list bears the name. Ancestors protect, descendants honored. Mazu's grace shines on the scholar's robe.",
        "interpretation": "Great fortune in study. Exams: success. Admission: name on the list. Thesis: likely passed.",
        "allusion": "Imperial exam candidates of old would visit both Wenchang and Mazu temples for blessing. Mazu is also honored as a patron of literature and education.",
        "modernNotes": ["Exam: top results", "Admission: smooth", "Thesis: passed", "Study abroad: offer comes"]
    },
    17: {
        "title": "The Noble One Shows the Way",
        "poem": "The road ahead is vast, do not wander in doubt. A noble one points the way with bright light. Walk the right path and you shall be rewarded — do not betray a single good thought in your heart.",
        "interpretation": "Career with noble help, but one's own effort is needed. For those seeking matters, a guide shall appear.",
        "allusion": "Liu Bei visited the thatched cottage three times to invite Zhuge Liang, who became his chief advisor and helped him found the Shu Han. Noble helpers are rare; when found, treasure them.",
        "modernNotes": ["Job search: a referral comes", "Startup: a mentor appears", "Transfer: an introduction", "Investment: a guide's advice"]
    },
    18: {
        "title": "Withered Tree Meets Spring",
        "poem": "The withered tree, meeting spring, sprouts again. The long illness, healed, sees the morning sun. The sick who draw this sign are greatly blessed. Reborn, renewed, ten thousand homes.",
        "interpretation": "Health improves, or career turns. The sick: recovery. Career: out of danger into safety.",
        "allusion": "In Daoism, the withered tree meets spring — a metaphor for finding life at the brink of death.",
        "modernNotes": ["Illness: recovery", "Career: turnaround", "Fortune: improving", "Study: progress"]
    },
    19: {
        "title": "Peach Blossoms Bloom",
        "poem": "Peach trees, young and bright, their blossoms glowing. A spring breeze comes once to your house. A good match is heaven-sent, not of human hands — only wait for the east wind, and one tree of flowers.",
        "interpretation": "Great fortune in love. Singles: a right person comes soon. Dating: success.",
        "allusion": "The Book of Songs' \"Peach Blossoms Young\" — a wedding celebration.",
        "modernNotes": ["Single: a good match comes", "Dating: success", "Reconciliation: fate not yet done", "Proposal: success"]
    },
    20: {
        "title": "Daily Gold, Doubloons In",
        "poem": "Day by day wealth comes, doubloons in. Business earns profit, gladdens the heart. But keep integrity as your root — never covet ill-gotten gold.",
        "interpretation": "Wealth flows. For those seeking money, gains come. But take the honest path; avoid speculation.",
        "allusion": "Mazu temples often have oil and incense donation boxes. Devotees donate to maintain the temple, symbolizing added wealth.",
        "modernNotes": ["Investment: honest gain", "Business: profit", "Side hustle: viable", "Speculation: not advisable"]
    },
    21: {
        "title": "The Sea of Learning Has No Shore",
        "poem": "The sea of learning has no shore; the boat of hardship sails on. By lamp at night, through many autumns. One morning the taste of books is grasped, and the road to the clouds is open.",
        "interpretation": "Upper-middle fortune in study. For exam takers: likely pass. For learners: persist.",
        "allusion": "Han Yu's \"Ancient and Modern Worthies\": in the mountain of books, the path is made by diligence; on the sea of learning, the boat is the hardship.",
        "modernNotes": ["Exam: likely pass", "Admission: effort needed", "Thesis: possible", "Study abroad: preparation needed"]
    },
    22: {
        "title": "Sailing with the Current",
        "poem": "Sailing with the current, no towing needed; a single light sail crosses the river ahead. Do not seek shortcuts on dangerous paths — straight the cloud-borne sail to cross the vast sea.",
        "interpretation": "Career flows smoothly, but stay steady. Do not chase quick wins.",
        "allusion": "Li Bai's verse: a day will come when the long wind breaks the waves; straight the cloud-borne sail to cross the vast sea.",
        "modernNotes": ["Career: smooth", "Investment: small gain", "Negotiation: favorable", "Urgent matters: slow down"]
    },
    23: {
        "title": "Settled in Peace, Joy in Labor",
        "poem": "Settled in peace, no need to seek a peach-blossom spring — this very place is a small heaven. Grandchildren at the knee bring joy; old and young together celebrate reunion.",
        "interpretation": "Family harmony, career stable. For those seeking a home, favorable. For family, peaceful.",
        "allusion": "Tao Yuanming's \"Peach Blossom Spring\": the yellow-haired and the pigtailed, all content and happy.",
        "modernNotes": ["Home buying: favorable", "Family: harmonious", "Career: stable", "Relocation: possible"]
    },
    24: {
        "title": "Peace Through the Four Seasons",
        "poem": "Spring brings fine flowers, summer cool. Autumn the bright moon, winter the sun. Four seasons of peace, no ill — the whole family, old and young, joy and health.",
        "interpretation": "Peace through all four seasons, no great misfortune. For health, the body is kept safe.",
        "allusion": "Folk tradition has spring couplets of \"peace through the four seasons,\" symbolizing a year without disaster.",
        "modernNotes": ["Year: peaceful", "Health: steady", "Family: harmonious", "Travel: smooth"]
    },
    25: {
        "title": "Hold Steady, Wait the Time",
        "poem": "Hold till the clouds part to see the moon; wait for the wind, and the sail is light. Seek not rapid advance but steady steps; when fortune turns, the road ahead opens.",
        "interpretation": "No rush, no panic — hold or advance, as fits. The current fortune is steady; hold, do not attack. Wait for the right time, and growth will follow.",
        "allusion": "Wang Zeng, prime minister of the Song dynasty, failed the imperial exam three times. Onlookers urged him to give up. He said: the moment has not come; I shall wait. He later became the top scorer and rose to the highest office.",
        "modernNotes": ["Job search: not smooth for now, but improvement will come", "Career: stable phase, do not thrash about", "Investment: observe", "Study: steady progress is enough"]
    },
    26: {
        "title": "Calm Heart, Steady Qi",
        "poem": "The heart, like still water, naturally at peace. No need for haste, no need for sleeplessness. One day of calm heart and steady qi — a thousand disasters cannot touch.",
        "interpretation": "Today, be still rather than act. Think thrice before every move.",
        "allusion": "Zhuge Liang's \"Admonition to My Son\": without detachment, one cannot clarify one's purpose; without tranquility, one cannot reach far.",
        "modernNotes": ["Today: stable", "Decisions: wait for the right moment", "Emotions: steady", "Urgent matters: slow"]
    },
    27: {
        "title": "Husband and Wife as Honored Guests",
        "poem": "Husband and wife honor each other as guests, in harmony through all the days. Do not let small things hurt the peace — growing old together is the truest blessing.",
        "interpretation": "Middle-grade fortune in love. Honor and tolerate each other; understand one another.",
        "allusion": "The Zuo Zhuan records: there are four kinds of guests; husband and wife should honor each other as guests.",
        "modernNotes": ["Marriage: stable", "Dating: mutual respect", "Family: fewer quarrels", "In-laws: more patience"]
    },
    28: {
        "title": "A Long, Steady Stream",
        "poem": "Do not chase sudden wealth or windfall. A long, steady stream flows slowly. Thrift and care bring family peace; small savings grow into fortune.",
        "interpretation": "Middle-grade fortune in wealth. Be frugal; avoid speculation.",
        "allusion": "Zhu Xi's \"Family Instructions\": a bowl of rice, a dish of soup — think how hard they were to obtain.",
        "modernNotes": ["Income: stable", "Investment: conservative", "Side hustle: take it slow", "Big spending: pause"]
    },
    29: {
        "title": "Years at the Cold Window",
        "poem": "Ten years at the cold window, with a green lamp; hard reading of poetry builds resolve. One day when the wind and clouds meet, the rooster spreads its wings to the heavenly court.",
        "interpretation": "Middle-grade fortune in study. Continue to work hard; do not slack.",
        "allusion": "Jin dynasty's Sun Kang, too poor for a candle, read by the snow's reflection; Che Yin read by glow-worms in a bag.",
        "modernNotes": ["Exam: effort required", "Study: persist", "Thesis: possible", "Study abroad: prepare"]
    },
    30: {
        "title": "Cultivate Body and Mind",
        "poem": "Cultivate body and mind, and peace is natural. Moderate food, regular rest. No troubles in the heart, the body is well — long life needs not ask of Heaven or Earth.",
        "interpretation": "Middle-grade fortune in health. Nurture life; tend the body.",
        "allusion": "Confucius' Analects: food finely prepared, meat finely sliced.",
        "modernNotes": ["Health: pay attention", "Diet: moderate", "Exercise: persist", "Sleep: regular"]
    },
}

# 自动简繁转换
def s2t(s):
    out = []
    for ch in s:
        out.append(S2T.get(ch, ch))
    return ''.join(out)

# 给每支加 i18n
for sign in data:
    sid = sign['id']
    if sid in translations:
        t = translations[sid]
        sign['i18n'] = {
            'zh_TW': {
                'title': s2t(sign['title']),
                'poem': s2t(sign['poem']),
                'interpretation': s2t(sign['interpretation']),
                'allusion': s2t(sign['allusion']),
                'modernNotes': [s2t(n) for n in sign['modernNotes']],
            },
            'en': t,
        }

with open('assets/data/signs.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# 验证
with open('assets/data/signs.json', 'r', encoding='utf-8') as f:
    data2 = json.load(f)
for s in data2:
    if 'i18n' in s and s['id'] <= 30:
        print(f"  #{s['id']} {s['title']} / {s['i18n']['zh_TW']['title']} / {s['i18n']['en']['title']}")
print(f"\n完成：{sum(1 for s in data2 if 'i18n' in s)} 支签文带 i18n")
