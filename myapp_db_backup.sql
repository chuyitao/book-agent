CREATE DATABASE IF NOT EXISTS myapp_db;
USE myapp_db;
create table book
(
    id         bigint unsigned auto_increment comment '自增主键ID'
        primary key,
    title      varchar(200)                       not null comment '图书名',
    author     varchar(120)                       not null comment '作者',
    type       tinyint                            not null comment '图书类型:1科幻 2文学 3小说 4童话 5古典 6推理 7散文 8传记 9社科',
    cover_url  varchar(512)                       null comment '封面图URL',
    summary    varchar(2000)                      null comment '简介',
    created_at datetime default CURRENT_TIMESTAMP not null comment '创建日期',
    updated_at datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改日期'
)
    comment '图书表';

INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (1, '三体', '刘慈欣', 1, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.7LjAIJqGnMq6dsmIbrlvFAHaK2?w=128&h=187&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '《三体》是刘慈欣创作的科幻三部曲，也是亚洲首部雨果奖获奖作品。小说始于红岸工程，天文学家叶文洁向宇宙发出信号，意外联络上身处三星混乱星系的三体文明。三体人因母星环境恶劣，意图侵占地球，派出智子封锁人类基础科学发展。人类启动面壁计划对抗危机，主角罗辑参悟宇宙黑暗森林法则，以星际威慑暂时平衡两大文明。后续威慑崩塌，三体大举入侵，人类在逃亡与抗争中，卷入降维打击、宇宙归零等终极命题。作品格局恢弘，融合硬核科幻、社会现实与人性拷问，是中国科幻里程碑之作。', '2026-05-15 06:37:26', '2026-05-15 11:10:26');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (2, '平凡的世界', '路遥', 2, 'https://tse3-mm.cn.bing.net/th/id/OIP-C.WWV4VzQPVuGEv7taqnQIjwAAAA?w=141&h=206&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '70-80年代陕北城乡青年的奋斗与命运。', '2026-05-15 06:37:26', '2026-05-15 10:55:16');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (3, '活着', '余华', 2, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.Q19mnfKD5GIiYvvGpwme9AHaK1?w=126&h=184&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '福贵一生亲人相继离世，最后只剩老牛相伴。', '2026-05-15 06:37:26', '2026-05-15 10:55:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (4, '百年孤独', '加西亚·马尔克斯', 3, 'https://tse2-mm.cn.bing.net/th/id/OIP-C.unwe8ceU2-8Jf9SZB06GnAHaJe?w=158&h=201&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '布恩迪亚家族七代人的魔幻百年兴衰。', '2026-05-15 06:37:26', '2026-05-15 10:58:16');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (5, '小王子', '安托万·德·圣-埃克苏佩里', 4, 'https://tse3-mm.cn.bing.net/th/id/OIP-C.0koBXsf5-NnX7b93mceIpwHaK_?w=115&h=180&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '来自B-612星球的小王子星际旅行与爱。', '2026-05-15 06:37:26', '2026-05-15 11:14:16');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (6, '围城', '钱钟书', 3, 'https://tse1-mm.cn.bing.net/th/id/OIP-C.6rTLWz_mD7YuJiZjH4mAwAHaHZ?w=172&h=180&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '抗战知识分子在爱情、婚姻、事业中的困境。', '2026-05-15 06:37:26', '2026-05-15 11:13:34');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (7, '红楼梦', '曹雪芹', 5, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.wQ4snYYC6WS5akfmg5pEHwHaLH?w=138&h=207&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '四大家族兴衰与宝黛钗爱情悲剧。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (8, '西游记', '吴承恩', 5, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.l0tNqSN-q4kHWG269eQoiwHaHa?w=197&h=197&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '唐僧师徒西天取经，九九八十一难。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (9, '水浒传', '施耐庵', 5, 'https://tse1-mm.cn.bing.net/th/id/OIP-C.SKr_OiQGriy6R7qs1rXtywHaKY?w=128&h=180&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '一百零八位梁山好汉的忠义与反抗。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (10, '三国演义', '罗贯中', 5, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.FXx6b9M-SGiEPp_g5O5HAAHaKY?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3', '魏蜀吴三国争霸，近百年历史风云。', '2026-05-15 06:37:26', '2026-05-15 11:00:35');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (11, '嫌疑人X的献身', '东野圭吾', 6, 'https://tse1-mm.cn.bing.net/th/id/OIP-C.eYEnfNWf0q8Ne2JZiGgTWQHaKg?w=197&h=280&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '天才数学家为邻居掩盖杀人真相。', '2026-05-15 06:37:26', '2026-05-15 11:14:16');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (12, '白夜行', '东野圭吾', 6, 'https://tse1-mm.cn.bing.net/th/id/OIP-C.dg1d4m_9N09uueXD_3xLegHaJj?w=148&h=191&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '跨越19年的罪案与共生关系。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (13, '解忧杂货店', '东野圭吾', 3, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.f0vozr_HWtpU0atomk-ptAHaKc?w=131&h=184&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '神奇杂货店能解答人们的烦恼。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (14, '挪威的森林', '村上春树', 3, 'https://tse1-mm.cn.bing.net/th/id/OIP-C.LBq3h8Vne-4HfZj3ciL8fQHaKr?w=146&h=210&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '渡边与直子、绿子的情感与生死思考。', '2026-05-15 06:37:26', '2026-05-15 11:14:35');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (15, '追风筝的人', '卡勒德·胡赛尼', 3, 'https://tse3-mm.cn.bing.net/th/id/OIP-C.b8Dlgsrxf648iEBTI_HQNwAAAA?w=141&h=200&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '阿富汗少年的友谊与救赎。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (16, '摆渡人', '克莱儿·麦克福尔', 3, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.D4puAQHFR0VqTgFtqkbRWAHaHa?w=216&h=216&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '灵魂摆渡人与女孩的守护与爱。', '2026-05-15 06:37:26', '2026-05-15 11:16:46');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (17, '云边有个小卖部', '张嘉佳', 7, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.WTcodoczju6YHfc6KLQzDwHaKX?w=157&h=218&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '小镇少年刘十三的成长与亲情。', '2026-05-15 06:37:26', '2026-05-15 11:00:35');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (18, '从你的全世界路过', '张嘉佳', 7, 'https://tse3-mm.cn.bing.net/th/id/OIP-C.B0i3pvVMnStHMa_5gPpYLgHaKe?w=197&h=279&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '33个温暖治愈的人间故事。', '2026-05-15 06:37:26', '2026-05-15 11:12:47');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (19, '你当像鸟飞往你的山', '塔拉·韦斯特弗', 8, 'https://tse4-mm.cn.bing.net/th/id/OIP-C.8_DAIBWvug9MZxuHCp-QxgHaHa?w=186&h=186&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3', '原生家庭桎梏下，教育带来自我救赎。', '2026-05-15 06:37:26', '2026-05-15 11:13:34');
INSERT INTO myapp_db.book (id, title, author, type, cover_url, summary, created_at, updated_at) VALUES (20, '人类简史', '尤瓦尔·赫拉利', 9, 'https://ts4.tc.mm.bing.net/th/id/OIP-C._9LKw_ClhhnqgWWNEHDL7QHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', '从认知革命到科学革命，人类发展大历史。', '2026-05-15 06:37:26', '2026-05-15 11:12:04');


create table book_price
(
    id            int auto_increment comment '主键id'
        primary key,
    book_id       int                                     not null comment '图书id',
    price         decimal(10, 2)                          not null comment '价格',
    discount_rate decimal(4, 2) default 1.00              null comment '优惠比例（0.00~1.00）',
    create_time   datetime      default CURRENT_TIMESTAMP null comment '创建日期',
    update_time   datetime      default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP comment '修改日期'
)
    comment '图书价格表' charset = utf8mb4;

INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (1, 1, 59.00, 1.00, '2026-01-01 10:00:00', '2026-01-01 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (2, 2, 45.50, 0.95, '2026-01-02 10:00:00', '2026-01-02 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (3, 3, 78.00, 0.90, '2026-01-03 10:00:00', '2026-01-03 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (4, 4, 32.00, 0.85, '2026-01-04 10:00:00', '2026-01-04 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (5, 5, 66.80, 0.92, '2026-01-05 10:00:00', '2026-01-05 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (6, 6, 29.90, 1.00, '2026-01-06 10:00:00', '2026-01-06 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (7, 7, 88.00, 0.80, '2026-01-07 10:00:00', '2026-01-07 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (8, 8, 52.00, 0.88, '2026-01-08 10:00:00', '2026-01-08 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (9, 9, 41.00, 0.93, '2026-01-09 10:00:00', '2026-01-09 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (10, 10, 75.00, 0.87, '2026-01-10 10:00:00', '2026-01-10 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (11, 11, 38.50, 0.96, '2026-01-11 10:00:00', '2026-01-11 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (12, 12, 69.00, 0.89, '2026-01-12 10:00:00', '2026-01-12 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (13, 13, 25.00, 1.00, '2026-01-13 10:00:00', '2026-01-13 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (14, 14, 92.00, 0.78, '2026-01-14 10:00:00', '2026-01-14 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (15, 15, 49.90, 0.91, '2026-01-15 10:00:00', '2026-01-15 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (16, 16, 55.00, 0.85, '2026-01-16 10:00:00', '2026-01-16 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (17, 17, 83.00, 0.82, '2026-01-17 10:00:00', '2026-01-17 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (18, 18, 33.30, 0.94, '2026-01-18 10:00:00', '2026-01-18 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (19, 19, 61.20, 0.90, '2026-01-19 10:00:00', '2026-01-19 10:00:00');
INSERT INTO myapp_db.book_price (id, book_id, price, discount_rate, create_time, update_time) VALUES (20, 20, 47.00, 0.86, '2026-01-20 10:00:00', '2026-01-20 10:00:00');


create table cart
(
    id         bigint unsigned auto_increment comment '主键ID'
        primary key,
    user_id    bigint unsigned                    not null comment '购物人ID',
    book_id    bigint unsigned                    not null comment '图书ID',
    created_at datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    updated_at datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间'
)
    comment '购物车表';

create index idx_cart_book
    on cart (book_id);

create index idx_cart_user
    on cart (user_id);

INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (4, 7, 7, '2026-05-15 09:58:01', '2026-05-15 09:58:01');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (9, 2, 2, '2026-05-15 11:05:18', '2026-05-15 11:05:18');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (10, 2, 3, '2026-05-15 11:05:24', '2026-05-15 11:05:24');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (11, 2, 4, '2026-05-15 11:05:44', '2026-05-15 11:05:44');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (13, 3, 2, '2026-05-15 11:21:24', '2026-05-15 11:21:24');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (15, 6, 4, '2026-05-15 13:14:56', '2026-05-15 13:14:56');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (16, 6, 1, '2026-05-15 15:54:07', '2026-05-15 15:54:07');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (17, 7, 1, '2026-05-15 16:50:10', '2026-05-15 16:50:10');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (18, 7, 17, '2026-05-15 16:51:35', '2026-05-15 16:51:35');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (28, 7, 15, '2026-05-15 16:52:20', '2026-05-15 16:52:20');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (29, 7, 16, '2026-05-15 16:52:23', '2026-05-15 16:52:23');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (30, 2, 9, '2026-05-15 17:04:07', '2026-05-15 17:04:07');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (31, 5, 2, '2026-05-18 07:04:16', '2026-05-18 07:04:16');
INSERT INTO myapp_db.cart (id, user_id, book_id, created_at, updated_at) VALUES (32, 5, 7, '2026-05-18 07:04:25', '2026-05-18 07:04:25');






create table user
(
    id            bigint auto_increment comment '用户ID，主键'
        primary key,
    username      varchar(64)       not null comment '登录用户名，唯一',
    name          varchar(100)      not null comment '用户真实姓名/显示名',
    password      varchar(64)       not null comment '密码哈希值',
    email         varchar(255)      null comment '邮箱',
    phone         varchar(20)       null comment '手机号',
    status        tinyint default 1 not null comment '状态：1-正常，0-禁用',
    created_at    datetime          not null comment '创建时间',
    updated_at    datetime          not null comment '最后更新时间',
    last_login_at datetime          null comment '最后登录时间',
    login_count   int     default 0 not null comment '登录次数',
    constraint uk_username
        unique (username)
)
    comment '用户表';

create index idx_name
    on user (name);

create index idx_username
    on user (username);

INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (1, 'zhangsan', '张三', '123456', 'zhangsan@example.com', '13800138001', 1, '2026-04-24 02:48:36', '2026-04-24 02:48:36', null, 0);
INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (2, 'lisi', '李四', '123456', 'lisi@example.com', '13800138002', 1, '2026-04-24 02:48:36', '2026-04-24 02:48:36', null, 0);
INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (3, 'wangwu', '王五', '123456', 'wangwu@example.com', '13800138003', 1, '2026-04-24 02:48:36', '2026-04-24 02:48:36', null, 0);
INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (4, 'admin', '系统管理员', '123456', 'admin@example.com', '13800138000', 1, '2026-04-24 02:48:36', '2026-04-24 02:48:36', null, 0);
INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (5, 'test', '测试用户', '123456', 'test@example.com', '13800138999', 1, '2026-04-24 02:48:36', '2026-04-24 02:48:36', null, 0);
INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (6, '范德萨范德萨', '地方都是', 'dfsdfdfs', '3123213213', '123213213', 1, '2026-04-24 11:27:38', '2026-04-24 11:27:38', null, 0);
INSERT INTO myapp_db.user (id, username, name, password, email, phone, status, created_at, updated_at, last_login_at, login_count) VALUES (7, 'chuyitao', '储贻涛', 'cyt123456', 'itcyt@qq.com', '13080512293', 1, '2026-04-25 19:39:38', '2026-04-25 19:39:38', null, 0);








