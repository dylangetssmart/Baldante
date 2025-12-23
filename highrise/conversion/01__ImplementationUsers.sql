use SATenantConsolidated_Tabs3_and_MyCase
go


--SELECT DISTINCT [user_id] FROM PracticeMasterBaldante..CMJRNL WHERE isnull([user_id],'') <> ''

if exists (
	 select
		 *
	 from sys.objects
	 where name = 'implementation_users'
		 and type = 'U'
	)
begin
	drop table implementation_users
end

go

create table implementation_users (
	Syst			VARCHAR(10),
	Staff			VARCHAR(50),
	SAloginID		VARCHAR(20),
	SAFirst			VARCHAR(50),
	SALast			VARCHAR(50),
	SAusrnUserID	INT,
	SAusrnContactID INT
)
go

insert into implementation_users
	(
		Syst,
		Staff,
		SAFirst,
		SALast,
		SAloginID
	)
	select
		'T3',
		'ADAMD',
		'Adam',
		'D',
		'AdamD'
	union
	select
		'HR',
		'Aimee W.',
		'Aimee',
		'W',
		'AimeeW'
	union
	select
		'HR',
		'Ally C.',
		'Ally',
		'C',
		'AllyC'
	union
	select
		'T3',
		'AMYC',
		'Amy',
		'C',
		'AmyC'
	union
	select
		'T3',
		'AMY',
		'Amy',
		'C',
		'AmyC'
	union
	select
		'T3',
		'ANDREAM',
		'Andrea',
		'M',
		'AndreaM'
	union
	select
		'HR',
		'Andrea Y.',
		'Andrea',
		'Y',
		'AndreaY'
	union
	select
		'HR',
		'Annalise F.',
		'Annalise',
		'Felicien',
		'AnnaliseF'
	union
	select
		'HR',
		'Anthony P.',
		'Anthony',
		'P',
		'AnthonyP'
	union
	select
		'MC',
		'',
		'Aron',
		'Minkoff',
		'AronM'
	union
	select
		'T3',
		'ARONM',
		'Aron',
		'Minkoff',
		'AronM'
	union
	select
		'HR',
		'Banita W.',
		'Banita',
		'W',
		'BanitaW'
	union
	select
		'HR',
		'Brandon M.',
		'Brandon',
		'M',
		'BrandonM'
	union
	select
		'HR',
		'Caroline G.',
		'Caroline',
		'Goldstein',
		'CarolineG'
	union
	select
		'T3',
		'CAROLINEG',
		'Caroline',
		'Goldstein',
		'CarolineG'
	union
	select
		'MC',
		'',
		'Cecilia',
		'Bright',
		'CelieB'
	union
	select
		'T3',
		'CELIEB',
		'Cecilia',
		'Bright',
		'CelieB'
	union
	select
		'HR',
		'Cheryl K.',
		'Cheryl',
		'Klucaric',
		'CherylK'
	union
	select
		'MC',
		'',
		'Cheryl',
		'Klucaric',
		'CherylK'
	union
	select
		'T3',
		'CHERYLK',
		'Cheryl',
		'Klucaric',
		'CherylK'
	union
	select
		'T3',
		'CHRISTYM',
		'Christy',
		'M',
		'ChristyM'
	union
	select
		'T3',
		'CTM',
		'Christy',
		'M',
		'ChristyM'
	union
	select
		'T3',
		'CLAREW',
		'Clare',
		'W',
		'ClareW'
	union
	select
		'HR',
		'Corina H.',
		'Corina',
		'H',
		'CorinaH'
	union
	select
		'HR',
		'Corinne M.',
		'Corinne',
		'Morgan',
		'CorinneM'
	union
	select
		'MC',
		'',
		'Corinne',
		'Morgan',
		'CorinneM'
	union
	select
		'T3',
		'CORINNEM',
		'Corinne',
		'Morgan',
		'CorinneM'
	union
	select
		'HR',
		'Corinne N.',
		'Corinne',
		'Noyd',
		'CorinneN'
	union
	select
		'T3',
		'DANIELLA',
		'Daniella',
		'Price',
		'DaniellaP'
	union
	select
		'HR',
		'Danielle D.',
		'Danielle',
		'Derohannesian',
		'DanielleD'
	union
	select
		'T3',
		'DANIELLE',
		'Danielle',
		'Derohannesian',
		'DanielleD'
	union
	select
		'HR',
		'Danielle K.',
		'Danielle',
		'Kowalski',
		'DanielleK'
	union
	select
		'HR',
		'Danielle P.',
		'Daniella',
		'Price',
		'DaniellaP'
	union
	select
		'T3',
		'DARLENET',
		'Darlene',
		'T',
		'DarleneT'
	union
	select
		'HR',
		'Derveleen C.',
		'Derveleen',
		'C',
		'DerveleenC'
	union
	select
		'T3',
		'ELAINEB',
		'Elaine',
		'B',
		'ElaineB'
	union
	select
		'HR',
		'Ellen G.',
		'Ellen',
		'Gemberling',
		'EllenG'
	union
	select
		'MC',
		'',
		'Ellen',
		'Gemberling',
		'EllenG'
	union
	select
		'T3',
		'ELLENG',
		'Ellen',
		'Gemberling',
		'EllenG'
	union
	select
		'HR',
		'Emily K.',
		'Emily',
		'Knight',
		'EmilyK'
	union
	select
		'T3',
		'ERICKC',
		'Erick',
		'C',
		'ErickC'
	union
	select
		'HR',
		'Ethan D.',
		'Ethan',
		'Durand',
		'EthanD'
	union
	select
		'MC',
		'',
		'Ethan',
		'Durand',
		'EthanD'
	union
	select
		'HR',
		'Eva L.',
		'Eva',
		'L',
		'EvaL'
	union
	select
		'HR',
		'Eve B.',
		'Eve',
		'B',
		'EveB'
	union
	select
		'HR',
		'Gabreil M.',
		'Gabriel',
		'Magee',
		'GabreilM'
	union
	select
		'T3',
		'GABRIEL',
		'Gabriel',
		'Magee',
		'GabreilM'
	union
	select
		'HR',
		'Grace W.',
		'Grace',
		'Welsh',
		'GraceW'
	union
	select
		'HR',
		'Hallie R.',
		'Hallie',
		'R',
		'HallieR'
	union
	select
		'T3',
		'JACKC',
		'Jack',
		'C',
		'JackC'
	union
	select
		'HR',
		'Jamie H.',
		'Jamie',
		'Hutchinson',
		'JamieH'
	union
	select
		'T3',
		'JAMIEH',
		'Jamie',
		'Hutchinson',
		'JamieH'
	union
	select
		'HR',
		'Johanna C.',
		'Johanna',
		'C',
		'JohannaC'
	union
	select
		'MC',
		'',
		'John',
		'Baldante',
		'JohnB'
	union
	select
		'T3',
		'JOHNB',
		'John',
		'Baldante',
		'JohnB'
	union
	select
		'HR',
		'Jonathan S.',
		'Jonathan',
		'S',
		'JonathanS'
	union
	select
		'HR',
		'Juankenia G.',
		'Juankenia',
		'G',
		'JuankeniaG'
	union
	select
		'HR',
		'Kaitlin S.',
		'Kaitlin',
		'S',
		'KaitlinS'
	union
	select
		'MC',
		'',
		'Kathleen',
		'Butler',
		'KathleenB'
	union
	select
		'HR',
		'Kathleen M.',
		'Kathleen',
		'M',
		'KathleenM'
	union
	select
		'T3',
		'KATHM',
		'Kath',
		'M',
		'KathM'
	union
	select
		'T3',
		'KM',
		'Kath',
		'M',
		'KathM'
	union
	select
		'HR',
		'Kevin P.',
		'Kevin',
		'P',
		'KevinP'
	union
	select
		'MC',
		'',
		'Kyle',
		'Keller',
		'KyleK'
	union
	select
		'T3',
		'KYLEK',
		'Kyle',
		'Keller',
		'KyleK'
	union
	select
		'T3',
		'LAWRENCE',
		'Lawrence',
		'Finney',
		'LawrenceF'
	union
	select
		'HR',
		'Mark C.',
		'Mark',
		'Cohen',
		'MarkC'
	union
	select
		'MC',
		'',
		'Mark',
		'Cohen',
		'MarkC'
	union
	select
		'T3',
		'MARKC',
		'Mark',
		'Cohen',
		'MarkC'
	union
	select
		'T3',
		'MARKL',
		'Mark',
		'Levy',
		'MarkL'
	union
	select
		'T3',
		'MARTING',
		'Martin',
		'Rubenstein',
		'MartinR'
	union
	select
		'HR',
		'Martin R.',
		'Martin',
		'Rubenstein',
		'MartinR'
	union
	select
		'MC',
		'',
		'Martin',
		'Rubenstein',
		'MartinR'
	union
	select
		'HR',
		'Mary D.',
		'Mary',
		'D',
		'MaryD'
	union
	select
		'HR',
		'Maureen K.',
		'Maureen',
		'K',
		'MaureenK'
	union
	select
		'T3',
		'MDD',
		'MDD',
		'',
		'MDD'
	union
	select
		'T3',
		'MELISSAW',
		'Melissa',
		'W',
		'MelissaW'
	union
	select
		'T3',
		'MICHELEN',
		'Michele',
		'N',
		'MicheleN'
	union
	select
		'HR',
		'Mistye S.',
		'Mistye',
		'Stack',
		'MistyeS'
	union
	select
		'HR',
		'Mobin C.',
		'Mobin',
		'C',
		'MobinC'
	union
	select
		'HR',
		'Nick K.',
		'Nick',
		'K',
		'NickK'
	union
	select
		'T3',
		'RANNICAA',
		'Rannica',
		'A',
		'RannicaA'
	union
	select
		'T3',
		'RICKB',
		'Rick',
		'B',
		'RickB'
	union
	select
		'T3',
		'RIMMAB',
		'Rimma',
		'B',
		'RimmaB'
	union
	select
		'HR',
		'Sandra L.',
		'Sandra',
		'L',
		'SandraL'
	union
	select
		'HR',
		'Sarah G.',
		'Sarah',
		'G',
		'SarahG'
	union
	select
		'HR',
		'Sarahlyn M.',
		'Sarahlyn',
		'M',
		'SarahlynM'
	union
	select
		'T3',
		'SARAK',
		'Sara',
		'K',
		'SaraK'
	union
	select
		'HR',
		'Selene B.',
		'Selene',
		'B',
		'SeleneB'
	union
	select
		'HR',
		'Shanna M.',
		'Shanna',
		'M',
		'ShannaM'
	union
	select
		'HR',
		'Sharise P.',
		'Sharise',
		'P',
		'ShariseP'
	union
	select
		'T3',
		'SHARISEP',
		'Sharise',
		'P',
		'ShariseP'
	union
	select
		'T3',
		'SP',
		'Sharise',
		'P',
		'ShariseP'
	union
	select
		'HR',
		'Shawni G.',
		'Shawni',
		'Gilbert',
		'ShawniG'
	union
	select
		'MC',
		'',
		'Shawni',
		'Gilbert',
		'ShawniG'
	union
	select
		'HR',
		'Shelby K.',
		'Shelby',
		'K',
		'ShelbyK'
	union
	select
		'HR',
		'Sophia A.',
		'Sophia',
		'Abramson',
		'SophiaA'
	union
	select
		'HR',
		'Stacy H.',
		'Stacy',
		'Hughes',
		'StacyH'
	union
	select
		'HR',
		'Steve M.',
		'Steve',
		'M',
		'SteveM'
	union
	select
		'HR',
		'Suzanne A.',
		'Suzanne',
		'A',
		'SuzanneA'
	union
	select
		'HR',
		'Taylor G.',
		'Taylor',
		'Gordon',
		'TaylorG'
	union
	select
		'HR',
		'Taylor H.',
		'Taylor',
		'H',
		'TaylorH'
	union
	select
		'T3',
		'THERESAC',
		'Theresa',
		'C',
		'TheresaC'
	union
	select
		'HR',
		'Thomas F.',
		'Thomas',
		'F',
		'ThomasF'
	union
	select
		'MC',
		'',
		'Tracey',
		'Del Giorno',
		'TraceyD'
	union
	select
		'MC',
		'',
		'Troy',
		'Carey',
		'TroyC'
	union
	select
		'T3',
		'TROYC',
		'Troy',
		'Carey',
		'TroyC'
	union
	select
		'HR',
		'Val S.',
		'Val',
		'Sauler',
		'ValS'
	union
	select
		'MC',
		'',
		'Val',
		'Sauler',
		'ValS'
	union
	select
		'T3',
		'VALS',
		'Val',
		'Sauler',
		'ValS'
	union
	select
		'MC',
		'',
		'Yvonne',
		'Marple',
		'YvonneM'



update iu
set SAusrnUserID = u.usrnUserID,
	SAusrncontactID = u.usrnContactID
from implementation_users iu
left join [sma_MST_Users] u
	on u.[usrsLoginID] = iu.saloginid
go