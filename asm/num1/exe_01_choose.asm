include irvine32.inc
.data
item1 db '[1]ѡ������	[2]ð������',0
item2 db '[3]��������	[4]��������',0
item3 db '[5]������	[6]ȫ����',0
item4 db '[7]��ŵ��	[8]������',0
item5 db '[9]��������	[10]�ж�����Ԫ��',0
item6 db '[11]�������	[12]�˻ʺ�����',0
item7 db '[13]�Թ�����	[14]���ֲ���',0
item8 db '������ѡ�',0

menu dd offset item1
     dd offset item2
     dd offset item3
     dd offset item4
     dd offset item5
     dd offset item6
     dd offset item7
     dd offset item8

msg1 db 'ѡ������',0
msg2 db 'ð������',0
msg3 db '��������',0
msg4 db '��������',0
msg5 db '������',0
msg6 db 'ȫ����',0
msg7 db '��ŵ��',0
msg8 db '������',0
msg9 db '��������',0
msg10 db '�ж�����Ԫ��',0
msg11 db '�������',0
msg12 db '�˻ʺ�����',0
msg13 db '�Թ�����',0
msg14 db '���ֲ���',0

choice dd offset msg1
       dd offset msg2
       dd offset msg3
       dd offset msg4
       dd offset msg5
       dd offset msg6
       dd offset msg7
       dd offset msg8
       dd offset msg9
       dd offset msg10
       dd offset msg11
       dd offset msg12
       dd offset msg13
       dd offset msg14
.code
displayMenu proc
	mov esi,0
again:cmp esi,8
	jge final
	mov edx,menu[4 * esi]
	call writestring
	call crlf
	add esi,1
	jmp again
final:
	ret
displayMenu endp
main proc
	call displayMenu
	call readint
	mov edx,choice[4 * eax - 4]
	call writestring
	exit
main endp
end main