#!/usr/bin/env python3
"""批量给 signs.json 的 #31-#60 加 i18n 字段（zh_TW + en）。"""
import json

# 简→繁字形映射（覆盖签文常用字）
S2T = {
    "缘": "緣", "宾": "賓", "烛": "燭", "毕": "畢", "营": "營",
    "兹": "茲", "气": "氣", "爱": "愛", "将": "將", "头": "頭",
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
    "亲": "親", "从": "從", "伤": "傷", "怀": "懷", "态": "態",
    "怜": "憐", "迟": "遲", "选": "選", "纵": "縱", "结": "結",
    "绪": "緒", "围": "圍", "园": "園", "图": "圖", "场": "場",
    "块": "塊", "复": "複", "侠": "俠", "俩": "倆", "偿": "償",
    "兑": "兌", "党": "黨", "兴": "興", "养": "養", "兽": "獸",
    "内": "內", "冈": "岡", "册": "冊", "军": "軍", "农": "農",
    "冯": "馮", "华": "華", "协": "協", "联": "聯", "丽": "麗",
    "机": "機", "权": "權", "极": "極", "杨": "楊", "构": "構",
    "标": "標", "栋": "棟", "栏": "欄", "树": "樹", "样": "樣",
    "桥": "橋", "检": "檢", "楼": "樓", "横": "橫", "樱": "櫻",
    "现": "現", "点": "點", "灯": "燈", "炉": "爐", "热": "熱",
    "烦": "煩", "环": "環", "画": "畫", "畅": "暢", "盖": "蓋",
    "盘": "盤", "监": "監", "种": "種", "积": "積", "称": "稱",
    "稳": "穩", "穷": "窮", "签": "籤", "简": "簡", "篮": "籃",
    "类": "類", "紧": "緊", "线": "線", "组": "組", "细": "細",
    "终": "終", "绍": "紹", "绕": "繞", "继": "繼", "维": "維",
    "综": "綜", "绿": "綠", "缠": "纏", "缩": "縮", "缺": "缺",
    "置": "置", "联": "聯", "义": "義", "习": "習", "翘": "翹",
    "翻": "翻", "联": "聯", "聪": "聰", "脏": "臟", "脱": "脫",
    "脸": "臉", "脏": "臟", "脑": "腦", "脚": "腳", "肠": "腸",
    "脏": "臟", "胆": "膽", "胀": "脹", "脏": "臟", "腊": "臘",
    "脱": "脫", "脸": "臉", "脑": "腦", "脏": "臟", "胆": "膽",
    "萨": "薩", "莲": "蓮", "获": "獲", "莱": "萊", "莹": "瑩",
    "萧": "蕭", "萨": "薩", "虚": "虛", "虫": "蟲", "虾": "蝦",
    "蛮": "蠻", "装": "裝", "裤": "褲", "视": "視", "观": "觀",
    "规": "規", "览": "覽", "让": "讓", "议": "議", "记": "記",
    "讲": "講", "认": "認", "识": "識", "议": "議", "让": "讓",
    "谢": "謝", "谣": "謠", "谦": "謙", "谨": "謹", "谬": "謬",
    "谭": "譚", "誉": "譽", "讴": "謳", "贾": "賈", "赖": "賴",
    "赚": "賺", "赛": "賽", "赞": "讚", "赠": "贈", "赢": "贏",
    "赞": "讚", "赤": "赤", "赵": "趙", "赶": "趕", "趋": "趨",
    "跌": "跌", "践": "踐", "跷": "蹺", "蹒": "蹣", "蹭": "蹭",
    "车": "車", "轨": "軌", "轮": "輪", "软": "軟", "转": "轉",
    "轮": "輪", "辉": "輝", "辈": "輩", "输": "輸", "辞": "辭",
    "辨": "辨", "辩": "辯", "边": "邊", "辽": "遼", "达": "達",
    "迁": "遷", "过": "過", "迈": "邁", "运": "運", "还": "還",
    "这": "這", "远": "遠", "违": "違", "连": "連", "迟": "遲",
    "迫": "迫", "迹": "跡", "适": "適", "选": "選", "逊": "遜",
    "递": "遞", "远": "遠", "违": "違", "迟": "遲", "迁": "遷",
    "选": "選", "逊": "遜", "递": "遞", "远": "遠", "适": "適",
    "邮": "郵", "部": "部", "都": "都", "鄙": "鄙", "酉": "酉",
    "酱": "醬", "酿": "釀", "醇": "醇", "醉": "醉", "醋": "醋",
    "酱": "醬", "醍": "醍", "醐": "醐", "醚": "醚", "醛": "醛",
    "钦": "欽", "钩": "鈎", "钱": "錢", "钳": "鉗", "铁": "鐵",
    "铃": "鈴", "铅": "鉛", "铜": "銅", "银": "銀", "销": "銷",
    "锁": "鎖", "锅": "鍋", "锈": "鏽", "锋": "鋒", "锐": "銳",
    "错": "錯", "锚": "錨", "锣": "鑼", "锤": "錘", "锦": "錦",
    "键": "鍵", "锁": "鎖", "镜": "鏡", "长": "長", "门": "門",
    "闭": "閉", "问": "問", "闯": "闖", "阔": "闊", "队": "隊",
    "阶": "階", "陆": "陸", "阵": "陣", "阴": "陰", "阵": "陣",
    "阶": "階", "陆": "陸", "陈": "陳", "险": "險", "陷": "陷",
    "隐": "隱", "难": "難", "雇": "雇", "雉": "雉", "雪": "雪",
    "雾": "霧", "韦": "韋", "页": "頁", "项": "項", "顺": "順",
    "须": "須", "顽": "頑", "顾": "顧", "顿": "頓", "颂": "頌",
    "预": "預", "领": "領", "颇": "頗", "颈": "頸", "颊": "頰",
    "频": "頻", "颓": "頹", "颗": "顆", "题": "題", "颜": "顏",
    "额": "額", "颠": "顛", "颤": "顫", "风": "風", "飘": "飄",
    "饮": "飲", "饭": "飯", "饱": "飽", "饼": "餅", "饿": "餓",
    "余": "餘", "馏": "餾", "馆": "館", "马": "馬", "驰": "馳",
    "驱": "驅", "驳": "駁", "驴": "驢", "驶": "駛", "驻": "駐",
    "驾": "駕", "驿": "驛", "验": "驗", "骤": "驟", "体": "體",
    "髅": "髏", "鱼": "魚", "鸟": "鳥", "鸡": "雞", "鸣": "鳴",
    "鸦": "鴉", "鸽": "鴿", "鸾": "鸞", "鸿": "鴻", "鹅": "鵝",
    "鹰": "鷹", "黄": "黃", "齐": "齊", "齿": "齒", "龄": "齡",
    "龙": "龍", "龟": "龜",
}

# 加载现有 signs.json
with open('assets/data/signs.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 翻译数据（#31-#60）
translations = {
    31: {
        "title": "Contentment, Constant Joy",
        "poem": "The contented one finds joy within, free from greed and rivalry, far from disaster. Simple tea and plain rice, eaten at peace, surpass the finest ambrosia and immortal fruit.",
        "interpretation": "Today, be content. Do not compare yourself to others.",
        "allusion": "Dao De Jing: Those who know contentment are not disgraced; those who know when to stop are not endangered.",
        "modernNotes": ["Today: at peace", "Mind: settle", "Material: enough", "Spirit: rich"]
    },
    32: {
        "title": "Harmony Brings Auspice",
        "poem": "A house of harmony bears good fortune; the old and young are all at peace. Do not let words stir a rift; patience and tolerance bring long blessings.",
        "interpretation": "Middle-grade fortune in family. Be gentle; do not quarrel.",
        "allusion": "Zhou Yi · Qian: Preserve the great harmony; it benefits and is correct.",
        "modernNotes": ["Family: harmonious", "Conflict: dissolve", "Relationships: maintain", "Elders: respect"]
    },
    33: {
        "title": "Keep the Mouth Sealed",
        "poem": "Illness enters through the mouth, disaster through words. Careful in private and small things, safety begins. Close the mouth, hide the tongue — avoid troubles that come to your side.",
        "interpretation": "Be silent; watch your words. For career, beware of the small-minded; for love, avoid biting words. This sign warns of trouble from speech — think three times before you speak.",
        "allusion": "Ming dynasty's Yang Shen, for speaking out, was exiled to Yunnan. His wife Huang E advised: too many words invite loss; keep the mouth as sealed as a bottle. Heeding this, he devoted himself to writing and met a good end.",
        "modernNotes": ["At work: speak less, do more; avoid giving colleagues a handle", "In love: don't dig up the past, don't say harsh things in anger", "At home: careful words, avoid family conflict", "In social life: lay low for a while"]
    },
    34: {
        "title": "Beware Fire and Candle",
        "poem": "Out and about, be cautious — fire, candle, blade, and weapon all need care. One moment of inattention brings disaster. Begin and end with care, and peace is kept.",
        "interpretation": "Middle-lower fortune in health and travel. Be careful; prevent accidents.",
        "allusion": "The folk saying \"beware of fire and candle\" reminds one to be cautious in both home and travel.",
        "modernNotes": ["Travel: safety first", "Health: check-up", "Work: careful", "Fire: inspect"]
    },
    35: {
        "title": "Step Back, Sky Opens Wide",
        "poem": "Step back, and the sea and sky open wide. Yield three points, and the heart is at ease. Do not let small things harm the peace — patience and tolerance bring boundless blessings.",
        "interpretation": "Middle-lower fortune in love. Yield; do not fight for victory.",
        "allusion": "Qing dynasty's \"Maxim Couplets\": Step back, and the sea and sky are wide; yield three points, and how peaceful is the heart.",
        "modernNotes": ["Quarrels: yield", "Negotiation: concede", "Family: patience", "Conflict: dissolve"]
    },
    36: {
        "title": "Wealth Does Not Enter the Hurrying Door",
        "poem": "Wealth does not enter the hurried door; riches do not favor obsession. Do not chase quick money on dangerous paths; step by step, in safety, all is well.",
        "interpretation": "Middle-lower fortune in wealth. Be conservative; avoid speculation.",
        "allusion": "The old saying \"wealth does not enter the hurrying door\" advises prudence in financial matters.",
        "modernNotes": ["Investment: don't rush", "Side hustle: take it slow", "Speculation: not advisable", "Gambling: avoid"]
    },
    37: {
        "title": "Learning Reveals What We Lack",
        "poem": "Learning, then we know our lack; teaching, then we know our gaps. The humble seeker of advice is the wise one; pride and self-satisfaction block all progress.",
        "interpretation": "Middle-lower fortune in study. Be humble; do not be complacent.",
        "allusion": "Li Ji · Xue Ji: Learning, then we know our lack; teaching, then we know our gaps.",
        "modernNotes": ["Study: humble", "Exam: effort required", "Thesis: needs revision", "Study abroad: prepare"]
    },
    38: {
        "title": "Moderate Diet, Careful Living",
        "poem": "Moderate the diet, careful in living; do not indulge the mouth and harm the body. Early rise, early sleep, body and mind in health — long life needs not ask of immortals or physicians.",
        "interpretation": "Middle-lower fortune in health. Nurture life; do not be unrestrained.",
        "allusion": "Huang Di Nei Jing: Diet in measure, living in rhythm.",
        "modernNotes": ["Health: attention", "Diet: moderate", "Sleep: regular", "Exercise: persist"]
    },
    39: {
        "title": "Watch the Changes Quietly",
        "poem": "Watch the changes quietly, wait for the moment. Do not panic and lose your mind. Wind and clouds shift as is their way — hold till the clouds part to see the moon.",
        "interpretation": "Today, be still, not active. Wait for the situation to become clear.",
        "allusion": "Zhuge Liang's \"Admonition to My Son\": Stillness cultivates the self; thrift nourishes virtue.",
        "modernNotes": ["Today: wait", "Decisions: observe", "Investment: stay put", "Urgent matters: delay"]
    },
    40: {
        "title": "Keep the Petty at Distance",
        "poem": "Keep the petty at a distance, and peace comes. Be near the worthy, and the venture thrives. Do not associate with the treacherous; live a clean life and thank Mazu.",
        "interpretation": "Middle-lower fortune in career and family. Keep the small-minded at arm's length.",
        "allusion": "Confucius said: There are three有益 friends: the upright, the sincere, the well-informed.",
        "modernNotes": ["Coworkers: keep at distance", "Friends: choose carefully", "Partners: vet", "Family: harmonious"]
    },
    41: {
        "title": "Difficulty First, Ease After",
        "poem": "Do not complain the road ahead is rough; through wind and rain, your purpose does not shift. After hardship comes reward; mountain flowers bloom in the season of return.",
        "interpretation": "Although difficult now, a turn will come. For those who ask, hold on and do not give up — the hardship will pass, the result will brighten.",
        "allusion": "Han dynasty's Sima Qian, after suffering castration for the Li Ling affair, wished to end his life. His stepfather Ren An urged: hardship is the whetstone; enduring shame can complete the Records. He did, becoming the unmatched historian.",
        "modernNotes": ["Startup: current loss is normal, long-term looks good", "Job search: a few rejections are normal, the right one will come", "Love: after a breakup, you will meet the right person", "Health: chronic but manageable"]
    },
    42: {
        "title": "Broken Mirror, Round Again",
        "poem": "A broken mirror, round again, is rare in ancient tales; parting and reunion follow Heaven's design. Yet only after mending the self anew can the old love be joined once more.",
        "interpretation": "A small misfortune in love can be resolved. For reconciliation: possible, but requires change.",
        "allusion": "As the Southern Chen dynasty fell, the imperial son-in-law Xu Deyan and his wife Princess Lechang each kept half a broken mirror; later they were indeed reunited.",
        "modernNotes": ["Reconciliation: possible but requires effort", "Divorce: reversible", "Quarrels: resolvable", "Mindset: settle"]
    },
    43: {
        "title": "Turn Danger to Safety",
        "poem": "Turning danger to safety rests on sincerity; Mazu looks with compassion on all beings. Saved at the brink, in the end there is rescue — remember to give thanks to the divine.",
        "interpretation": "A small misfortune in health and travel can be resolved. From peril comes fortune.",
        "allusion": "There are many Mazu legends of saving those at sea. The most famous: a merchant ship met a storm, and Mazu appeared to save the sailors.",
        "modernNotes": ["Health: rescueable", "Travel: danger can pass", "Work: solvable", "Crisis: passable"]
    },
    44: {
        "title": "The Worst Passes, Fortune Returns",
        "poem": "When the worst turns, fortune comes anew; hardship ends, sweetness arrives. Do not despair at present trials — when fortune turns, all flows open and smooth.",
        "interpretation": "Today's fortune is small-unlucky, but resolving. A bounce back from the bottom.",
        "allusion": "Zhou Yi · Pi: When Pi (obstruction) reaches its extreme, Tai (prosperity) comes.",
        "modernNotes": ["Today: improving", "Difficulty: solvable", "Investment: can recover", "Career: turnaround"]
    },
    45: {
        "title": "Lost in the East, Gained in the West",
        "poem": "Lost in the east, gained in the west; do not let small setbacks dim the road ahead. Present loss is not total defeat — gain another day, and thank Mazu.",
        "interpretation": "A small misfortune in wealth can be resolved. Loss returns to gain.",
        "allusion": "Hou Han Shu · Biography of Feng Yi: Lost in the east, gained in the mulberry trees of the west.",
        "modernNotes": ["Investment: can recover", "Side hustle: turnaround", "Speculation: recoverable", "Lost items: findable"]
    },
    46: {
        "title": "The Prodigal Returns",
        "poem": "The prodigal's return is worth more than gold; mending the self anew, thanks to Mazu. Do not despair at one misstep; rebuild the family ways and stand once more.",
        "interpretation": "A small misfortune in family can be resolved. The wanderer can return.",
        "allusion": "The traditional opera \"The Prodigal Returns\" tells the story of one who turns back.",
        "modernNotes": ["Family member: can return", "Children: teachable", "Conflict: resolvable", "Relationship: repairable"]
    },
    47: {
        "title": "Bitterness Ends, Sweetness Comes",
        "poem": "Bitterness ends, sweetness comes in time; through hardship, your purpose does not shift. Do not lose faith in trials; one day the wind and clouds become the moment.",
        "interpretation": "A small misfortune in career and study can be resolved. A turn will come.",
        "allusion": "The traditional saying: bitterness ends, sweetness comes.",
        "modernNotes": ["Career: turnaround", "Study: progress", "Startup: breakthrough", "Exam: success"]
    },
    48: {
        "title": "Vigilance in Solitude",
        "poem": "In the hidden room, conscience sees as clearly as divine eyes; alone, one owes nothing to shadow or companion. A single slip, a thousand miles apart — keep reverence and fear, walk the level path.",
        "interpretation": "Matters are not going smoothly, often from an unclean heart or improper conduct. Reflect on oneself; cast out bad habits, and a turn will come.",
        "allusion": "Song dynasty's Zengzi said: I examine myself three times each day. With daily self-reflection and a clear heart, all goes well.",
        "modernNotes": ["Career: project not going well — consider whether the method is wrong", "Love: maybe you have behaved inappropriately", "Wealth: maybe you spend too freely", "Health: maybe your habits are the problem"]
    },
    49: {
        "title": "Hold to Simplicity",
        "poem": "Hold to simplicity, do not vie with others; the slow bird that flies first also wins. Do not learn deceit and lose trust — plain and unadorned, thank Mazu.",
        "interpretation": "Today's fortune is small-unlucky. Hold to simplicity; do not flaunt.",
        "allusion": "Zeng Guofan: Only the utmost sincerity in the world can overcome the utmost deception; only the utmost simplicity in the world can overcome the utmost cunning.",
        "modernNotes": ["Today: hold", "Decisions: wait", "Work: lay low", "Investment: stay put"]
    },
    50: {
        "title": "Hold the Hearth, Value Home",
        "poem": "To hold the hearth and value home is a tradition of old; leaving home and hearth brings bitter words. If you can keep your place with care, it surpasses drifting in foreign lands.",
        "interpretation": "A small misfortune in travel and family. Not advisable to travel far; stay home.",
        "allusion": "Han Shu · Yuan Di Ji: To hold the hearth and value relocation is the nature of the people.",
        "modernNotes": ["Relocation: not urgent", "Long journey: delay", "Going abroad: wait", "Stay home: ok"]
    },
    51: {
        "title": "Adding Wood to the Fire",
        "poem": "Adding wood to a fire only fans it higher; the more you fight, the harder to contain. Do not chase small gains before you, lest a great disaster brew beyond repair.",
        "interpretation": "A small misfortune in wealth and career. Do not charge forward.",
        "allusion": "Shi Ji · Qin Shi Huang Ben Ji: Adding wood to a fire.",
        "modernNotes": ["Investment: cut losses", "Side hustle: pause", "Speculation: no", "Gambling: stay away"]
    },
    52: {
        "title": "The Bow at Full Draw",
        "poem": "The bow at full draw cannot pierce silk; spirit spent, body and mind exhausted. Do not force yourself to push through; rest, recover, and then fly again.",
        "interpretation": "A small misfortune in health. Rest and recover.",
        "allusion": "Shi Ji · Han Changru Lie Zhuan: At full draw, the bow cannot pierce even the lightest silk of Lu.",
        "modernNotes": ["Health: rest", "Work: slow", "Exercise: pause", "Emotion: settle"]
    },
    53: {
        "title": "Spilled Water, Beyond Recall",
        "poem": "Spilled water into the ground cannot be gathered; the parting song has risen, no turning back. Old love like a dream, gone with the wind — do not cling, do not hold, but let go.",
        "interpretation": "In love, the matter is decided; it cannot be recovered. For those asking about reconciliation, the divine does not permit. Let go of the past; look forward.",
        "allusion": "Shang dynasty's Jiang Ziya's wife Ma, unable to bear Jiang's poverty, left him. Later Jiang assisted King Wen of Zhou to greatness. Ma came to seek reunion. Jiang took water and poured it on the ground, asking Ma: can the water be gathered back?",
        "modernNotes": ["Breakup: may really be over", "Reconciliation: don't force; release yourself and the other", "Divorce: irreversible, accept reality", "Unrequited love: they don't love you"]
    },
    54: {
        "title": "The Reins of Fame and Profit",
        "poem": "Reins of fame and profit bind the hero; many a great soul dreams in vain. Do not lose your true heart for hollow name; quiet and peaceful, thank Mazu.",
        "interpretation": "A small misfortune in career and wealth. Let go of fame and profit.",
        "allusion": "Qin Shi Huang and Han Wu Di sought immortality and Dao, and all came to nothing.",
        "modernNotes": ["Career: settle", "Investment: no greed", "Comparison: release", "Mind: rich"]
    },
    55: {
        "title": "Behind Closed Doors, Reflect",
        "poem": "Retreat to the inner chamber, examine the self; sit behind closed doors, thank the worldly dust. One wrong thought, a thousand miles astray; only in regret does one know the day has sunk.",
        "interpretation": "Currently a major difficulty; pause all action, reflect on one's faults. To advance now is to lose; to hold back is best.",
        "allusion": "Spring and Autumn period, the Jin minister Zhao Dun's family, because of Zhao Kuo's paper-warrior talk, suffered the great defeat of the Battle of Changping. The whole clan retired behind closed doors to reflect for three years; later the Zhao orphan continued the line.",
        "modernNotes": ["Career: not the time to start or expand", "Investment: cut losses on losing projects", "Love: cooling-off period, no decisions", "Health: rest well, don't push"]
    },
    56: {
        "title": "Halt the Step",
        "poem": "A ten-thousand-foot cliff ahead; halting the step brings peace. Do not boast a moment's bravery; one step back, the sea and sky open wide.",
        "interpretation": "A great misfortune in travel. Do not proceed.",
        "allusion": "Rein in the horse at the cliff; turning back is the shore.",
        "modernNotes": ["Travel: no", "Investment: stop", "Decisions: slow", "Job change: wait"]
    },
    57: {
        "title": "Change Course, Begin Anew",
        "poem": "The old road is hard to travel; change the strings, begin anew. Do not lose the road ahead through stubbornness; self-renewal brings rescue — change the old view, all flows open.",
        "interpretation": "A great misfortune in career and study. A thorough change is needed.",
        "allusion": "Shang Yang's reforms, a complete change of course, made Qin strong.",
        "modernNotes": ["Career: transform", "Study: change direction", "Job change: ok", "Startup: pivot"]
    },
    58: {
        "title": "Rein in at the Cliff's Edge",
        "poem": "Rein in at the cliff while there is still time; a misstep and the fall brings endless regret. Withdraw bravely from the torrent, return whole — do not wait till caught in the depths to hesitate.",
        "interpretation": "A great misfortune in wealth and health. Turn back in time.",
        "allusion": "Buddhism speaks of the boundless sea of suffering; turning back is the shore.",
        "modernNotes": ["Investment: cut losses", "Health: check", "Side hustle: pause", "Gambling: quit"]
    },
    59: {
        "title": "Wait for Heaven's Time",
        "poem": "Thunder and rain together, shut the door for now; sit in stillness, wait for the dawn. When fortune turns, the wind and clouds shift; from the worst, prosperity rises, all things new.",
        "interpretation": "Currently the fortune is at its lowest; do not act rashly. Be still; when the time comes, a turn will come by itself.",
        "allusion": "Three Kingdoms period, Zhuge Liang tilled in Nanyang for ten years, waiting for Liu Bei's three visits to the thatched cottage, before he came out to build a great achievement. If the time had not come, going out early would not have brought success.",
        "modernNotes": ["Job search: no offers right now, wait for the economic cycle", "Startup: market is bad now, wait", "Investment: cash is king, don't bottom-fish", "Love: fate not yet ripe, first improve yourself"]
    },
    60: {
        "title": "Turning Back is the Shore",
        "poem": "The sea of suffering is boundless; do not act rashly. Turning back is the shore, thank Mazu. One stray thought, a thousand miles apart; lay down the butcher's knife, become a Buddha on the spot.",
        "interpretation": "A great misfortune in love and family. Turn back.",
        "allusion": "Buddhism: lay down the butcher's knife, become a Buddha on the spot.",
        "modernNotes": ["Love: let go", "Family: reconcile", "Divorce: reconsider", "Reconciliation: difficult"]
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
for s in data2[30:60]:
    if 'i18n' in s:
        print(f"  #{s['id']} {s['title']} / {s['i18n']['zh_TW']['title']} / {s['i18n']['en']['title']}")
print(f"\n完成：{sum(1 for s in data2 if 'i18n' in s)} 支签文带 i18n")
