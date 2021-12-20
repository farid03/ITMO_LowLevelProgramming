%define NEXT 0
%macro colon 2
	%ifid %2			
		%2: dq NEXT
		%define NEXT %2
	%else
		%error "Некорректно задана метка!"
	%endif
	%ifstr %1
		db %1, 0
	%else
		%error "Некорректно задан ключ. Ключ должен быть строкой!"
	%endif
%endmacro 
