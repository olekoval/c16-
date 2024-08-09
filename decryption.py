import csv

class Df():
    """"""
 
    def update_nan(self, df, fields):
        """заміна NaN на порожню строку"""
        for fl in fields:
            df[fl] = df[fl].fillna("")
            
    def update_date(self, df, fields):
        """заміна object на datetime64[ns]"""
        for fd in fields:
            df[fd] = df[fd].astype("datetime64[ns]")
            df[fd] = df[fd].dt.date
            
    def decryption_diagnos(self, df, dct, filed):
        df[filed] = df[filed].apply(lambda s: f"{s} - {dct.setdefault(s, '')}" 
        if s != "" else s)
        
    def decryption_result(self, df, dct, filed):
        df[filed] = df[filed].apply(lambda s: f"{dct.setdefault(s, '')}" if s != "" else s)
        
    def  decryption_interv_diag(self, df, dct, filed):
        """Розшифровка строки з кодами записаним через кому"""
        
        def sub(s):
            lst = str(s).split(",")
            st = ''
            if s != "":
                finish = len(lst) - 1
                for j, i in enumerate(lst):
                    if j == finish:
                        st = st + f"{i} - {dct.setdefault(i, '')}"
                    else:    
                        st = st + f"{i} - {dct.setdefault(i, '')} | "
                return st  
            else:
                return s
        df[filed] = df[filed].apply(sub)
        
    def sex(self, df, filed):
        """Розшифровка статі пацієнта"""
        
        df[filed] = df[filed].apply(lambda s: "Чоловік" if s == "MALE" else "Жінка")
        
    def write_excel(self, df, file_name):
        df.to_excel(file_name, index=False)


class CsvToDict():
    """Читає файл csv та створює словник"""
    
    def __init__(self, path, delimiter):
        """де, path - шлях до csv файлу, delimiter - роздільник
        між ключем та його значенням"""
        
        self.path = path
        self.delimiter = delimiter
        
    def create_dict(self):
        """Читає файл self.path та створює і повертає словник
        запоненний значеннями зі строк які мають вигляд:
        "A33|Правець новонародженого|eHealth/ICD10_AM/condition_codes"
        або
        "discharge_worse,Виписаний(а) з погіршенням"
        """
        
        with open(self.path, encoding='UTF-8') as f:
            # створення списка списків
            rd = list(csv.reader(f, delimiter=self.delimiter))
            dt = dict()
            for i in rd:
                dt[i[0]] = i[1]
        return dt
