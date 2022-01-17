%define NEXT 0
%macro colon 2
	%ifid %2			
		%2: dq NEXT
		%define NEXT %2
	%else
		%fatal "Некорректно задана метка!"
	%endif
	%ifstr %1
		db %1, 0
	%else
		%fatal "Некорректно задан ключ. Ключ должен быть строкой!"
	%endif
%endmacro 
