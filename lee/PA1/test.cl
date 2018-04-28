
(* START FROM HERE *)

(* Test COMMENTS *)
(* *)
(************)
(**)
(*(*(**)*)*)

(* 1st (* 2nd (* 3rd *) * ) *)
(* 1234567890 *)
"String String String"

--This is for checking

ELSE Else ELSe ElSe eLse elsE

CLASS ClASS ClaSS cLASS ClAsS CLASs ClAss cLass clASs claSS

IsVOID ISvoid isvOiD 

FI IF if fi iF fI

While WHILE WHilE WhILE wHILE whiLE wHilE 

Loop LOOP loOp loOP LOop

InherITS inheritS INHERits InHErits

Not noT nOt

- = + / * = < ~ , : ; ( @ ) { }

(* CHECKING STRING *)

"Is this string "
"is this smart "
" 123456789"
" space space      space		tab	tab		tab	enter "

" isvoid : this is string "

(* arrow *)
<=
=>
<-
%
(* Test Null Character *)




" IS THIS WORKING \
  OR NO? "

12 325125 92330900000000

21380948213409832092341890

9999999999999999999998888888888888888888888888877777777777777777777766666666665555555555

193848.1239329329

0.000000002








(* models one-dimensional cellular automaton on a circle of finite radius
   arrays are faked as Strings,
   X's respresent live cells, dots represent dead cells,
   no error checking is done *)
class CellularAutomaton inherits IO {
    population_map : String;
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
   
    print() : SELF_TYPE {
        {
            out_string(population_map.concat("\n"));
            self;
        }
    };
   
    num_cells() : Int {
        population_map.length()
    };
   
    cell(position : Int) : String {
        population_map.substr(position, 1)
    };
   
    cell_left_neighbor(position : Int) : String {
        if position = 0 then
            cell(num_cells() - 1)
        else
            cell(position - 1)
        fi
    };
   
    cell_right_neighbor(position : Int) : String {
        if position = num_cells() - 1 then
            cell(0)
        else
            cell(position + 1)
        fi
    };
   
    (* a cell will live if exactly 1 of itself and it's immediate
       neighbors are alive *)
    cell_at_next_evolution(position : Int) : String {
        if (if cell(position) = "X" then 1 else 0 fi
            + if cell_left_neighbor(position) = "X" then 1 else 0 fi
            + if cell_right_neighbor(position) = "X" then 1 else 0 fi
            = 1)
        then
            "X"
        else
            '.'
        fi
    };
   
    evolve() : SELF_TYPE {
        (let position : Int in
        (let num : Int <- num_cells[] in
        (let temp : String in
            {
                while position < num loop
                    {
                        temp <- temp.concat(cell_at_next_evolution(position));
                        position <- position + 1;
                    }
                pool;
                population_map <- temp;
                self;
            }
        ) ) )
    };
};

class Main {
    cells : CellularAutomaton;
   
    main() : SELF_TYPE {
        {
            cells <- (new CellularAutomaton).init("         X         ");
            cells.print();
            (let countdown : Int <- 20 in
                while countdown > 0 loop
                    {
                        cells.evolve();
                        cells.print();
                        countdown <- countdown - 1;
                    
                pool
            ) 
            self;
        }
    };
};








