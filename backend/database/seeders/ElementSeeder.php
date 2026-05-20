<?php

namespace Database\Seeders;

use App\Models\Element;
use App\Models\Language;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ElementSeeder extends Seeder
{
    use ForeignKeyGuard;

    public function run(): void
    {
        // Avval mavjud ma'lumotlarni tozalaymiz
        $this->withoutForeignKeys(function () {
            Element::truncate();
            DB::table('element_translations')->truncate();
        });

        $uz = Language::where('code', 'uz')->first();
        $ru = Language::where('code', 'ru')->first();
        $en = Language::where('code', 'en')->first();

        $elements = [
            ['n'=>1,'s'=>"H",'nm'=>"Vodorod",'m'=>1.008,'p'=>1,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>2,'s'=>"He",'nm'=>"Geliy",'m'=>4.003,'p'=>1,'c'=>"noble",'hex'=>"#F48FB1"],
            ['n'=>3,'s'=>"Li",'nm'=>"Litiy",'m'=>6.941,'p'=>2,'c'=>"alkali",'hex'=>"#FF8A80"],
            ['n'=>4,'s'=>"Be",'nm'=>"Berilliy",'m'=>9.012,'p'=>2,'c'=>"alkaline",'hex'=>"#FFD180"],
            ['n'=>5,'s'=>"B",'nm'=>"Bor",'m'=>10.811,'p'=>2,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>6,'s'=>"C",'nm'=>"Uglerod",'m'=>12.011,'p'=>2,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>7,'s'=>"N",'nm'=>"Azot",'m'=>14.007,'p'=>2,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>8,'s'=>"O",'nm'=>"Kislorod",'m'=>15.999,'p'=>2,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>9,'s'=>"F",'nm'=>"Ftor",'m'=>18.998,'p'=>2,'c'=>"halogen",'hex'=>"#CE93D8"],
            ['n'=>10,'s'=>"Ne",'nm'=>"Neon",'m'=>20.18,'p'=>2,'c'=>"noble",'hex'=>"#F48FB1"],
            ['n'=>11,'s'=>"Na",'nm'=>"Natriy",'m'=>22.99,'p'=>3,'c'=>"alkali",'hex'=>"#FF8A80"],
            ['n'=>12,'s'=>"Mg",'nm'=>"Magniy",'m'=>24.305,'p'=>3,'c'=>"alkaline",'hex'=>"#FFD180"],
            ['n'=>13,'s'=>"Al",'nm'=>"Alyuminiy",'m'=>26.982,'p'=>3,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>14,'s'=>"Si",'nm'=>"Kremniy",'m'=>28.086,'p'=>3,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>15,'s'=>"P",'nm'=>"Fosfor",'m'=>30.974,'p'=>3,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>16,'s'=>"S",'nm'=>"Oltingugurt",'m'=>32.06,'p'=>3,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>17,'s'=>"Cl",'nm'=>"Xlor",'m'=>35.45,'p'=>3,'c'=>"halogen",'hex'=>"#CE93D8"],
            ['n'=>18,'s'=>"Ar",'nm'=>"Argon",'m'=>39.948,'p'=>3,'c'=>"noble",'hex'=>"#F48FB1"],
            ['n'=>19,'s'=>"K",'nm'=>"Kaliy",'m'=>39.098,'p'=>4,'c'=>"alkali",'hex'=>"#FF8A80"],
            ['n'=>20,'s'=>"Ca",'nm'=>"Kaltsiy",'m'=>40.078,'p'=>4,'c'=>"alkaline",'hex'=>"#FFD180"],
            ['n'=>21,'s'=>"Sc",'nm'=>"Skandiy",'m'=>44.956,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>22,'s'=>"Ti",'nm'=>"Titan",'m'=>47.867,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>23,'s'=>"V",'nm'=>"Vanadiy",'m'=>50.942,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>24,'s'=>"Cr",'nm'=>"Xrom",'m'=>51.996,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>25,'s'=>"Mn",'nm'=>"Marganets",'m'=>54.938,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>26,'s'=>"Fe",'nm'=>"Temir",'m'=>55.845,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>27,'s'=>"Co",'nm'=>"Kobalt",'m'=>58.933,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>28,'s'=>"Ni",'nm'=>"Nikel",'m'=>58.693,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>29,'s'=>"Cu",'nm'=>"Mis",'m'=>63.546,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>30,'s'=>"Zn",'nm'=>"Rux",'m'=>65.38,'p'=>4,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>31,'s'=>"Ga",'nm'=>"Galliy",'m'=>69.723,'p'=>4,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>32,'s'=>"Ge",'nm'=>"Germaniy",'m'=>72.63,'p'=>4,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>33,'s'=>"As",'nm'=>"Mishyak",'m'=>74.922,'p'=>4,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>34,'s'=>"Se",'nm'=>"Selen",'m'=>78.971,'p'=>4,'c'=>"nonmetal",'hex'=>"#90CAF9"],
            ['n'=>35,'s'=>"Br",'nm'=>"Brom",'m'=>79.904,'p'=>4,'c'=>"halogen",'hex'=>"#CE93D8"],
            ['n'=>36,'s'=>"Kr",'nm'=>"Kripton",'m'=>83.798,'p'=>4,'c'=>"noble",'hex'=>"#F48FB1"],
            ['n'=>37,'s'=>"Rb",'nm'=>"Rubidiy",'m'=>85.468,'p'=>5,'c'=>"alkali",'hex'=>"#FF8A80"],
            ['n'=>38,'s'=>"Sr",'nm'=>"Stronsiy",'m'=>87.62,'p'=>5,'c'=>"alkaline",'hex'=>"#FFD180"],
            ['n'=>39,'s'=>"Y",'nm'=>"Itriy",'m'=>88.906,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>40,'s'=>"Zr",'nm'=>"Zirkoniy",'m'=>91.224,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>41,'s'=>"Nb",'nm'=>"Niobiy",'m'=>92.906,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>42,'s'=>"Mo",'nm'=>"Molibden",'m'=>95.95,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>43,'s'=>"Tc",'nm'=>"Texnetsiy",'m'=>98,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>44,'s'=>"Ru",'nm'=>"Ruteniy",'m'=>101.07,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>45,'s'=>"Rh",'nm'=>"Rodiy",'m'=>102.906,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>46,'s'=>"Pd",'nm'=>"Palladiy",'m'=>106.42,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>47,'s'=>"Ag",'nm'=>"Kumush",'m'=>107.868,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>48,'s'=>"Cd",'nm'=>"Kadmiy",'m'=>112.414,'p'=>5,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>49,'s'=>"In",'nm'=>"Indiy",'m'=>114.818,'p'=>5,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>50,'s'=>"Sn",'nm'=>"Qalay",'m'=>118.71,'p'=>5,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>51,'s'=>"Sb",'nm'=>"Surma",'m'=>121.76,'p'=>5,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>52,'s'=>"Te",'nm'=>"Tellur",'m'=>127.6,'p'=>5,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>53,'s'=>"I",'nm'=>"Yod",'m'=>126.904,'p'=>5,'c'=>"halogen",'hex'=>"#CE93D8"],
            ['n'=>54,'s'=>"Xe",'nm'=>"Ksenon",'m'=>131.293,'p'=>5,'c'=>"noble",'hex'=>"#F48FB1"],
            ['n'=>55,'s'=>"Cs",'nm'=>"Seziy",'m'=>132.905,'p'=>6,'c'=>"alkali",'hex'=>"#FF8A80"],
            ['n'=>56,'s'=>"Ba",'nm'=>"Bariy",'m'=>137.327,'p'=>6,'c'=>"alkaline",'hex'=>"#FFD180"],
            ['n'=>57,'s'=>"La",'nm'=>"Lantan",'m'=>138.905,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>58,'s'=>"Ce",'nm'=>"Seriy",'m'=>140.116,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>59,'s'=>"Pr",'nm'=>"Prazeodim",'m'=>140.908,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>60,'s'=>"Nd",'nm'=>"Neodim",'m'=>144.242,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>61,'s'=>"Pm",'nm'=>"Prometiy",'m'=>145,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>62,'s'=>"Sm",'nm'=>"Samariy",'m'=>150.36,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>63,'s'=>"Eu",'nm'=>"Evropiy",'m'=>151.964,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>64,'s'=>"Gd",'nm'=>"Gadoliniy",'m'=>157.25,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>65,'s'=>"Tb",'nm'=>"Terbiy",'m'=>158.925,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>66,'s'=>"Dy",'nm'=>"Disproziy",'m'=>162.5,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>67,'s'=>"Ho",'nm'=>"Golmiy",'m'=>164.93,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>68,'s'=>"Er",'nm'=>"Erbiy",'m'=>167.259,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>69,'s'=>"Tm",'nm'=>"Tuliy",'m'=>168.934,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>70,'s'=>"Yb",'nm'=>"Itterbiy",'m'=>173.045,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>71,'s'=>"Lu",'nm'=>"Lyutetiy",'m'=>174.967,'p'=>6,'c'=>"lanthanide",'hex'=>"#E6EE9C"],
            ['n'=>72,'s'=>"Hf",'nm'=>"Hafniy",'m'=>178.49,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>73,'s'=>"Ta",'nm'=>"Tantal",'m'=>180.948,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>74,'s'=>"W",'nm'=>"Volfram",'m'=>183.84,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>75,'s'=>"Re",'nm'=>"Reniy",'m'=>186.207,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>76,'s'=>"Os",'nm'=>"Osmiy",'m'=>190.23,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>77,'s'=>"Ir",'nm'=>"Iridiy",'m'=>192.217,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>78,'s'=>"Pt",'nm'=>"Platina",'m'=>195.084,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>79,'s'=>"Au",'nm'=>"Oltin",'m'=>196.967,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>80,'s'=>"Hg",'nm'=>"Simob",'m'=>200.592,'p'=>6,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>81,'s'=>"Tl",'nm'=>"Talliy",'m'=>204.38,'p'=>6,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>82,'s'=>"Pb",'nm'=>"Qo'rg'oshin",'m'=>207.2,'p'=>6,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>83,'s'=>"Bi",'nm'=>"Vismut",'m'=>208.98,'p'=>6,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>84,'s'=>"Po",'nm'=>"Poloniy",'m'=>209,'p'=>6,'c'=>"metalloid",'hex'=>"#80DEEA"],
            ['n'=>85,'s'=>"At",'nm'=>"Astat",'m'=>210,'p'=>6,'c'=>"halogen",'hex'=>"#CE93D8"],
            ['n'=>86,'s'=>"Rn",'nm'=>"Radon",'m'=>222,'p'=>6,'c'=>"noble",'hex'=>"#F48FB1"],
            ['n'=>87,'s'=>"Fr",'nm'=>"Fransiy",'m'=>223,'p'=>7,'c'=>"alkali",'hex'=>"#FF8A80"],
            ['n'=>88,'s'=>"Ra",'nm'=>"Radiy",'m'=>226,'p'=>7,'c'=>"alkaline",'hex'=>"#FFD180"],
            ['n'=>89,'s'=>"Ac",'nm'=>"Aktiniy",'m'=>227,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>90,'s'=>"Th",'nm'=>"Toriy",'m'=>232.038,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>91,'s'=>"Pa",'nm'=>"Protaktiniy",'m'=>231.036,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>92,'s'=>"U",'nm'=>"Uran",'m'=>238.029,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>93,'s'=>"Np",'nm'=>"Neptuniy",'m'=>237,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>94,'s'=>"Pu",'nm'=>"Plutoniy",'m'=>244,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>95,'s'=>"Am",'nm'=>"Ameritsiy",'m'=>243,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>96,'s'=>"Cm",'nm'=>"Kyuriy",'m'=>247,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>97,'s'=>"Bk",'nm'=>"Berkeliy",'m'=>247,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>98,'s'=>"Cf",'nm'=>"Kaliforniy",'m'=>251,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>99,'s'=>"Es",'nm'=>"Eynshteiniy",'m'=>252,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>100,'s'=>"Fm",'nm'=>"Fermiy",'m'=>257,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>101,'s'=>"Md",'nm'=>"Mendeleviy",'m'=>258,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>102,'s'=>"No",'nm'=>"Nobeliy",'m'=>259,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>103,'s'=>"Lr",'nm'=>"Lorensiy",'m'=>266,'p'=>7,'c'=>"actinide",'hex'=>"#791F1F"],
            ['n'=>104,'s'=>"Rf",'nm'=>"Rezerfordiy",'m'=>267,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>105,'s'=>"Db",'nm'=>"Dubniy",'m'=>268,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>106,'s'=>"Sg",'nm'=>"Siborgiy",'m'=>269,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>107,'s'=>"Bh",'nm'=>"Boriy",'m'=>270,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>108,'s'=>"Hs",'nm'=>"Xassiy",'m'=>269,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>109,'s'=>"Mt",'nm'=>"Meyteriy",'m'=>278,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>110,'s'=>"Ds",'nm'=>"Darmshtadtiy",'m'=>281,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>111,'s'=>"Rg",'nm'=>"Rentgeniy",'m'=>282,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>112,'s'=>"Cn",'nm'=>"Koperniysiy",'m'=>285,'p'=>7,'c'=>"transition",'hex'=>"#FFF59D"],
            ['n'=>113,'s'=>"Nh",'nm'=>"Nihoniy",'m'=>286,'p'=>7,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>114,'s'=>"Fl",'nm'=>"Fleroviy",'m'=>289,'p'=>7,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>115,'s'=>"Mc",'nm'=>"Moskoviy",'m'=>290,'p'=>7,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>116,'s'=>"Lv",'nm'=>"Livermoriy",'m'=>293,'p'=>7,'c'=>"metal",'hex'=>"#A5D6A7"],
            ['n'=>117,'s'=>"Ts",'nm'=>"Tennessiy",'m'=>294,'p'=>7,'c'=>"halogen",'hex'=>"#CE93D8"],
            ['n'=>118,'s'=>"Og",'nm'=>"Oganesson",'m'=>294,'p'=>7,'c'=>"noble",'hex'=>"#F48FB1"],
        ];

        foreach ($elements as $e) {
            $element = Element::create([
                'atomic_number' => $e['n'],
                'symbol' => $e['s'],
                'mass' => $e['m'],
                'type' => $e['c'],
                'color_hex' => $e['hex'],
            ]);

            // Add translations (Simple names for now, can be enriched)
            $element->translations()->create(['language_id' => $uz->id, 'name' => $e['nm']]);
            $element->translations()->create(['language_id' => $ru->id, 'name' => $this->getRuName($e['s'])]);
            $element->translations()->create(['language_id' => $en->id, 'name' => $this->getEnName($e['s'])]);
        }
    }

    private function getRuName($sym) {
        $map = ['H'=>"Водород",'He'=>"Гелий",'Li'=>"Литий",'Be'=>"Бериллий",'B'=>"Бор",'C'=>"Углерод",'N'=>"Азот",'O'=>"Кислород",'F'=>"Фтор",'Ne'=>"Неон",'Na'=>"Натрий",'Mg'=>"Магний",'Al'=>"Алюминий",'Si'=>"Кремний",'P'=>"Фосфор",'S'=>"Сера",'Cl'=>"Хлор",'Ar'=>"Аргон",'K'=>"Калий",'Ca'=>"Кальций",'Sc'=>"Скандий",'Ti'=>"Титан",'V'=>"Ванадий",'Cr'=>"Хром",'Mn'=>"Марганец",'Fe'=>"Железо",'Co'=>"Кобальт",'Ni'=>"Никель",'Cu'=>"Медь",'Zn'=>"Цинк",'Ga'=>"Галлий",'Ge'=>"Германий",'As'=>"Мышьяк",'Se'=>"Селен",'Br'=>"Бром",'Kr'=>"Криптон",'Rb'=>"Рубидий",'Sr'=>"Стронций",'Y'=>"Иттрий",'Zr'=>"Цирконий",'Nb'=>"Ниобий",'Mo'=>"Молибден",'Tc'=>"Технеций",'Ru'=>"Рутений",'Rh'=>"Родий",'Pd'=>"Палладий",'Ag'=>"Серебро",'Cd'=>"Кадмий",'In'=>"Индий",'Sn'=>"Олово",'Sb'=>"Сурьма",'Te'=>"Теллур",'I'=>"Йод",'Xe'=>"Ксенон",'Cs'=>"Цезий",'Ba'=>"Барий",'La'=>"Лантан",'Ce'=>"Церий",'Pr'=>"Празеодим",'Nd'=>"Неодим",'Pm'=>"Прометий",'Sm'=>"Самарий",'Eu'=>"Европий",'Gd'=>"Гадолиний",'Tb'=>"Тербий",'Dy'=>"Диспрозий",'Ho'=>"Гольмий",'Er'=>"Эрбий",'Tm'=>"Тулий",'Yb'=>"Иттербий",'Lu'=>"Лютеций",'Hf'=>"Гафний",'Ta'=>"Тантал",'W'=>"Вольфрам",'Re'=>"Рений",'Os'=>"Осмий",'Ir'=>"Иридий",'Pt'=>"Платина",'Au'=>"Золото",'Hg'=>"Ртуть",'Tl'=>"Таллий",'Pb'=>"Свинец",'Bi'=>"Висмут",'Po'=>"Полоний",'At'=>"Астат",'Rn'=>"Радон",'Fr'=>"Франций",'Ra'=>"Радий",'Ac'=>"Актиний",'Th'=>"Торий",'Pa'=>"Протактиний",'U'=>"Уран",'Np'=>"Нептуний",'Pu'=>"Плутоний",'Am'=>"Америций",'Cm'=>"Кюрий",'Bk'=>"Берклий",'Cf'=>"Калифорний",'Es'=>"Эйнштейний",'Fm'=>"Фермий",'Md'=>"Менделевий",'No'=>"Нобелий",'Lr'=>"Лоуренсий",'Rf'=>"Резерфордий",'Db'=>"Дубний",'Sg'=>"Сиборгий",'Bh'=>"Борий",'Hs'=>"Хассий",'Mt'=>"Мейтнерий",'Ds'=>"Дармштадтий",'Rg'=>"Рентгений",'Cn'=>"Коперниций",'Nh'=>"Нихоний",'Fl'=>"Флеровий",'Mc'=>"Московий",'Lv'=>"Ливерморий",'Ts'=>"Теннессин",'Og'=>"Оганесон"];
        return $map[$sym] ?? $sym;
    }

    private function getEnName($sym) {
        $map = ['H'=>"Hydrogen",'He'=>"Helium",'Li'=>"Lithium",'Be'=>"Beryllium",'B'=>"Boron",'C'=>"Carbon",'N'=>"Nitrogen",'O'=>"Oxygen",'F'=>"Fluorine",'Ne'=>"Neon",'Na'=>"Sodium",'Mg'=>"Magnesium",'Al'=>"Aluminium",'Si'=>"Silicon",'P'=>"Phosphorus",'S'=>"Sulfur",'Cl'=>"Chlorine",'Ar'=>"Argon",'K'=>"Potassium",'Ca'=>"Calcium",'Sc'=>"Scandium",'Ti'=>"Titanium",'V'=>"Vanadium",'Cr'=>"Chromium",'Mn'=>"Manganese",'Fe'=>"Iron",'Co'=>"Cobalt",'Ni'=>"Nickel",'Cu'=>"Copper",'Zn'=>"Zinc",'Ga'=>"Gallium",'Ge'=>"Germanium",'As'=>"Arsenic",'Se'=>"Selenium",'Br'=>"Bromine",'Kr'=>"Krypton",'Rb'=>"Rubidium",'Sr'=>"Strontium",'Y'=>"Yttrium",'Zr'=>"Zirconium",'Nb'=>"Niobium",'Mo'=>"Molybdenum",'Tc'=>"Technetium",'Ru'=>"Ruthenium",'Rh'=>"Rhodium",'Pd'=>"Palladium",'Ag'=>"Silver",'Cd'=>"Cadmium",'In'=>"Indium",'Sn'=>"Tin",'Sb'=>"Antimony",'Te'=>"Tellurium",'I'=>"Iodine",'Xe'=>"Xenon",'Cs'=>"Caesium",'Ba'=>"Barium",'La'=>"Lanthanum",'Ce'=>"Cerium",'Pr'=>"Praseodymium",'Nd'=>"Neodymium",'Pm'=>"Promethium",'Sm'=>"Samarium",'Eu'=>"Europium",'Gd'=>"Gadolinium",'Tb'=>"Terbium",'Dy'=>"Dysprosium",'Ho'=>"Holmium",'Er'=>"Erbium",'Tm'=>"Thulium",'Yb'=>"Ytterbium",'Lu'=>"Lutetium",'Hf'=>"Hafnium",'Ta'=>"Tantalum",'W'=>"Tungsten",'Re'=>"Rhenium",'Os'=>"Osmium",'Ir'=>"Iridium",'Pt'=>"Platinum",'Au'=>"Gold",'Hg'=>"Mercury",'Tl'=>"Thallium",'Pb'=>"Lead",'Bi'=>"Bismuth",'Po'=>"Polonium",'At'=>"Astatine",'Rn'=>"Radon",'Fr'=>"Francium",'Ra'=>"Radium",'Ac'=>"Actinium",'Th'=>"Thorium",'Pa'=>"Protactinium",'U'=>"Uranium",'Np'=>"Neptunium",'Pu'=>"Plutonium",'Am'=>"Americium",'Cm'=>"Curium",'Bk'=>"Berkelium",'Cf'=>"Californium",'Es'=>"Einsteinium",'Fm'=>"Fermium",'Md'=>"Mendelevium",'No'=>"Nobelium",'Lr'=>"Lawrencium",'Rf'=>"Rutherfordium",'Db'=>"Dubnium",'Sg'=>"Seaborgium",'Bh'=>"Bohrium",'Hs'=>"Hassium",'Mt'=>"Meitnerium",'Ds'=>"Darmstadtium",'Rg'=>"Roentgenium",'Cn'=>"Copernicium",'Nh'=>"Nihonium",'Fl'=>"Flerovium",'Mc'=>"Moscovium",'Lv'=>"Livermorium",'Ts'=>"Tennessine",'Og'=>"Oganesson"];
        return $map[$sym] ?? $sym;
    }
}
