CREATE TABLE `vehicle_categories2` (
    `name` varchar(60) NOT NULL,
    `label` varchar(60) NOT NULL,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `vehicles2` (
    `name` varchar(60) NOT NULL,
    `model` varchar(60) NOT NULL,
    `price` int NOT NULL,
    `category` varchar(60) DEFAULT NULL,
    PRIMARY KEY (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


REPLACE INTO `vehicle_categories2` (`name`, `label`) VALUES
('aviones', 'Aviones'),
('blindados', 'Blindados'),
('emergencias', 'Emergencias'),
('helicopteros', 'Helicopteros'),
('no blindados', 'No blindados'),
('tanques', 'Tanques'),

REPLACE INTO `vehicles2` (name, model, price, category) VALUES
('Tanque', 'abrams', 50, 'tanques'),
('Tanque2', 'abrams2', 50, 'tanques'),
('AH-64', 'ah64d', 80, 'helicopteros'),
('ares', 'ares', 10, 'no blindados'),
('Barracks', 'Barracks', 2, 'no blindados'),
('barrage', 'Barrage', 20, 'blindados'),
('minitanque', 'brad', 25, 'tanques'),
('minitanque2', 'brad2', 25, 'tanques'),
('hmmer', 'bspec', 5, 'blindados'),
('buzzard', 'buzzard', 30, 'helicopteros'),
('buzzard2', 'buzzard2', 20, 'helicopteros'),
('cargobob', 'cargobob', 40, 'helicopteros'),
('f15', 'f15s', 50, 'aviones'),
('f16', 'f16liaf', 50, 'aviones'),
('f22', 'f22a', 60, 'aviones'),
('H4R', 'H4REntityMTR', 15, 'no blindados'),
('H4Rx', 'H4RxST2', 10, 'no blindados'),
('hmmer con misiles', 'hasrad', 15, 'blindados'),
('havok', 'havok', 10, 'helicopteros'),
('Camion2', 'hmvs', 2, 'no blindados'),
('hunter', 'hunter', 50, 'helicopteros'),
('hycrh', 'hycrh7', 5, 'no blindados'),
('f35', 'hydra', 80, 'aviones'),
('Khanjali', 'Khanjali', 100, 'tanques'),
('tanquemedio', 'lav25ifv', 25, 'tanques'),
('lazer', 'lazer', 50, 'aviones'),
('tanque3', 'm1128s', 40, 'tanques'),
('antiareos', 'm142as', 15, 'tanques'),
('Camion4', 'm977hl', 2, 'no blindados'),
('Camion', 'man', 2, 'no blindados'),
('antiminas', 'mrap', 15, 'blindados'),
('hmmer con misiles2', 'msquaddie', 15, 'blindados'),
('Camion5', 'mtfft', 2, 'no blindados'),
('heli de transporte', 'nh90', 30, 'helicopteros'),
('policecar1', 'police2', 8, 'no blindados'),
('polvigeros', 'polvigerospeed', 5, 'no blindados'),
('rafalec', 'rafalec', 50, 'aviones'),
('rt3000', 'rt3000wb', 5, 'no blindados'),
('sherman', 'sherman', 30, 'tanques'),
('tiger', 'tiger', 25, 'tanques'),
('typhoon', 'typhoon', 50, 'aviones'),
('hmmer2', 'unarmed1', 5, 'blindados'),
('hmmer3', 'unarmed2', 5, 'blindados'),
('hmmer con torreta', 'uparmor', 10, 'blindados'),
('hmmer con torreta2', 'uparmorw', 10, 'blindados'),
('valkyrie', 'valkyrie', 40, 'helicopteros'),
('vigerozx', 'vigerozxwb', 8, 'no blindados'),

('jes', 'jes', 2, 'vip'),
('Honda Deluxe Edition', 'laneko', 3, 'vip'),
('Rimac Conceptone', 'rimac', 2, 'vip'),
('vip8', 'vip8', 2, 'vip'),
('Zentorno', 'zentorno', 5, 'vip'),

('Aperta', 'aperta', 5, 'ferrari'),
('F8 Tributo 2020', 'f8t', 4, 'ferrari'),
('F40', 'f40', 1, 'ferrari'),
('F812', 'f812', 2, 'ferrari'),
('Italia 458', '458', 5, 'ferrari'),
('2015 LaFerrari', 'laferrari', 5, 'ferrari'),
('Ferrari 488 Pista', 'pista', 5, 'ferrari'),

('ktklp7704', 'ktklp7704', 5, 'lambo'),
('Murcielago', 'lamboMurcielago', 3, 'lambo'),
('tmc', 'lamtmc', 5, 'lambo'),
('Centenario', 'rmodlp770', 5, 'lambo'),
('Gallardo', '2013LP560', 3, 'lambo'),
('Centenario LP 770-4', 'lp770', 3, 'lambo'),
('Sesto Elemento', 'lambose', 4, 'lambo'),
('Aventador Spyder', 'lp700r', 5, 'lambo'),

('P1 Latam', 'p1lm', 4, 'mclaren'),
('570S VORSTEINER 2016', 'mcvors', 3, 'mclaren'),
('Senna', 'senna', 5, 'mclaren'),

('Divo', 'divo', 5, 'bugatti'),
('Chiron', 'chiron17', 2, 'bugatti'),
('Veyron', 'bug09', 2, 'bugatti'),
('Chiron Pur Sport', 'bcps', 4, 'bugatti'),
('Centodieci', 'bugatticentodieci', 4, 'bugatti'),

('Vision GT', 'mvisiongt', 3, 'mercedes'),

('19GT500', '19gt500', 4, 'ford'),

('Agera', 'acsr', 1, 'koenigsegg'),
('Regera', 'regera', 5, 'koenigsegg'),

('Kawasaki h2carb', 'h2carb', 5, 'motos'),
('Shitzu hyabusadrag', 'hyabusadrag', 5, 'motos'),

('Fenyr Supersport', 'fenyr', 5, 'wmotors'),

('Corvette C7', 'C7', 5, 'chevrolet'),

('GT-R35', 'gtr', 5, 'nissan');
