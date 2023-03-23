# fitness-system-server

BAZA DANYCH SIŁOWNI/KLUBU FITNESS – ‘FITNESS-SYSTEM’

1. Podstawowe założenia projektu

Celem projektu było stworzenie bazy danych siłowni/klubu fitness. Jest to ‘fitness-system’ oparty na trzech głównych filarach: ludzie (‘People’, w tym ‘Customers’ i ‘Employees’), karnety (‘Tickets’) i zajęcia (‘Classes’).
‘Fitness-system’ jest systemem, w którym potencjalny klient może samodzielnie przez Internet założyć konto, wprowadzić swoje dane, kupić wybrany karnet a następnie zapisać się (jeżeli chce) na zajęcia. W ‘fitness-system’ można także dodać nowego pracownika, który również ma możliwość dodania nowego klienta do bazy, kupno mu karnetu lub zapisania na zajęcia (odpowiednik wizyty potencjalnego klienta stacjonarnie na siłowni). Pracownik ma także możliwość dodania nowych zajęć (do ‘Classes’). 
 
2. Logika systemu
1) Ludzie
Tabela ‘People’ zawiera dane osobowe zarówno pracowników, jak i klientów. Tabele ‘Employees’ i ‘Customers’ uzupełniają dane ludzi o specyficzne dla siebie informacje. Tabele te dziedziczą dane po tabeli ‘People’. 
Pracownicy: poza główną tabelą ‘Employees’ znajduje się tabela słownikowa dla ‘Employees’: ‘EmployeeCategories’, która zawiera wszystkie stanowiska pracy na tej siłowni.
	2) Zajęcia
	Tabela ‘Classes’ zawiera podstawowe informacje o konkretnych zajęciach. Dla ‘Classes’ tabelą słownikową jest tabela ‘ClassIntensities’ zawierająca informację o trzech poziomach intensywności zajęć. Tabela ‘ClassHarmonograms’ przechowuje dane o planowanym harmonogramie zajęć (np. jakieś zajęcia będą się odbywać w środy o 18:00 od 1 stycznia do 1 marca danego roku), tabela ‘ClassDetails’ dane o zajęciach odbywających się w konkretnym dniu, natomiast tabela ‘ClassRegistrations’ zawiera informacje o tym jaki klient na jakie zajęcia się zapisał. Logika systemu zakłada automatyczne codzienne aktualizacje harmonogramu zajęć, aby klient mógł się zapisywać na zajęcia z tygodniowym wyprzedzeniem. Na tabeli ‘ClassDetails’ utworzono także indeks ‘ClassDetailsIndex’ na atrybucie Date.
	3) Karnety
	Tabela ‘Tickets’ zawiera podstawowe informacje o konkretnych karnetach. W logice systemu ‘fitness-system’ istnieją dwa rodzaje karnetów: okresowe i ilościowe (dane o typach znajdują się w tabeli ‘TicketTypes’). Karnety okresowe (tabela ‘TicketsPeriodic’) posiadają konkretną datę ważności karnetu, zaś karnety ilościowe (tabela ‘TicketsQuantitative’) posiadają limit wejść (np. karnet na jedno wejście, na 13 wejść itd.) i nie posiadają daty ważności karnetu. Tabela ‘CustomerTickets’ zawiera całą historię zakupów karnetów przez klientów (łącznie z historyczną ceną, datą zakupu itd.). 
W tabeli ‘Entrances’ zawarte są informacje o każdorazowym wejściu na siłownię na danym karnecie danego klienta. Jest to niejako symulacja odbicia karty na recepcji siłowni przy wchodzeniu. Jeśli dana osoba nie ma aktywnego karnetu, to nie będzie mogła wejść.
W logice systemu ‘fitness-system’ przyjęto, że klient może z góry kupić tyle biletów ilościowych ile chce, jednakże nie może kupić biletu okresowego zaczynającego się w dacie, w której wciąż ma aktywny inny bilet okresowy.

WYZWALACZE
NAZWA	TABELA/WIDOK	OPIS
1. CustomersViewInsertTrigger	CustomersView 	Przy każdej próbie dodania nowego klienta uzupełnia obie tabele: ‘Customers’ i ‘People’
2. ClassRegistrationsInsertTrigger	ClassRegistrations	W trakcie zapisywania się klienta na dane zajęcia w przypadku braku wolnych miejsc na konkretne zajęcia nie pozwoli na nadpisanie miejsc, a wyświetli odpowiedni komunikat o błędzie
3. CustomerTicketsInsertTrigger	CustomerTickets	Zabezpieczenie przed kupnem biletu okresowego zaczynającego się w niedozwolonej dacie
4. CustomerDeleteTrigger	Customers	Zabezpieczenie przed całkowitym usunięciem klienta/klientów
5. CustomerTicketsUpdateDeleteTrigger	CustomerTickets	Uniemożliwienie usunięcia lub edycji danych w tej tabeli

FUNKCJE
NAZWA	ARGUMENTY	OPIS
1. hasAvailableSeats	@classDetailsID INT	Sprawdza, czy są jeszcze wolne miejsca na wskazane zajęcia
2. freeEntrances	@customerTicketID INT	Sprawdza ile pozostało jeszcze wolnych miejsc na danym bilecie ilościowym
3. hasActiveTicket	@personID INT	Sprawdza, czy dana osoba ma aktywny bilet
4. hasActivePeriodicTicket	@personID INT, @atDate DATE	Sprawdza, czy dana osoba ma aktywny bilet okresowy w dany dzień

WIDOKI
NAZWA	OPIS
1. CustomerActiveTickets	Przechowuje dane o biletach klientów: typ biletu i czy jest aktywny
2. ClassDetailsView	Przechowuje szczegółowe dane o każdych zajęciach (w tym aktualnie zajęte miejsca i maksymalna ilość miejsc)
3. EmployeesView	Przechowuje szczegółowe dane o pracownikach (z tabel People, Employees, EmployeeCategories) 
4. CustomersView	Przechowuje szczegółowe dane o klientach ( z tabel People i Customers)
5. AllTickets	Przechowuje dane o wszystkich rodzajach biletów (zarówno ilościowych jak i okresowych)
6. MonthProfits	Przechowuje informacje o miesięcznych zyskach z poszczególnych biletów

PROCEDURY
NAZWA	ARGUMENTY	OPIS
1. DisableCustomer	@personID INT	Dezaktywuje wskazanego klienta i usuwa jego dane z rezerwacji na zajęcia
2. AddEntrance	@personID INT	Jeśli wskazana osoba nie ma aktywnego karnetu, to wejście w ‘Entrances’ się nie naliczy, gdyż ta procedura przed tym zabezpiecza
3. TicketPurchase	@personID INT, @ticketID INT, @ticketStartDate DATE	Wstawia rekord do tabeli ‘CustomerTickets’, czyli symuluje kupno biletu. Uwaga: klient nie może kupić biletu okresowego obejmującego ten sam dzień, ale może kupić bilet ilościowy mając już aktywny bilet okresowy.
4. AddClassToHarmonogram	@dateToCheck DATE	Uzupełnia tabelę ‘ClassDetails’.
Na podstawie ‘ClassHarmonograms’ sprawdza, czy podana data na pewno jest możliwa do wstawienia i przypisania do konkretnych zajęć. 
Uwaga: logika systemu zakłada automatyczne codzienne aktualizacje harmonogramu zajęć, aby klient mógł się zapisywać na zajęcia z tygodniowym wyprzedzeniem.
5. MonthProfitsInYear	@Year NVARCHAR(4)	Wyświetla miesięczne profity z zakupów biletów we wskazanym roku 

3. Strategia pielęgnacji bazy danych (kopie zapasowe)
Kopie zapasowe powinny być robione automatycznie codziennie o 03:00 w nocy (z uwagi, że wtedy jest najmniejsze prawdopodobieństwo działań na bazie danych siłowni). Przechowywane byłyby ostatnie 7 bieżących kopii, czyli 7 dni wstecz oraz kopia z każdego pierwszego dnia miesiąca. Pozwoliłoby to na odtworzenie potrzebnych danych z bazy w przypadku problemów jednocześnie optymalizując wykorzystanie miejsca na przechowywanie kopii. Co kwartał wskazane jest odtwarzanie bazy danych z kopii, aby upewnić się ze mechanizm działa prawidłowo.
