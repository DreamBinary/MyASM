include irvine32.inc
.data
item1 db '[1]选择排序	[2]冒泡排序',0
item2 db '[3]插入排序	[4]快速排序',0
item3 db '[5]堆排序	[6]全排列',0
item4 db '[7]汉诺塔	[8]素数环',0
item5 db '[9]插入排序	[10]判定集合元素',0
item6 db '[11]整数拆分	[12]八皇后问题',0
item7 db '[13]迷宫问题	[14]二分查找',0
item8 db '请输入选项：',0

menu dd offset item1
     dd offset item2
     dd offset item3
     dd offset item4
     dd offset item5
     dd offset item6
     dd offset item7
     dd offset item8

msg1 db '选择排序',0
msg2 db '冒泡排序',0
msg3 db '插入排序',0
msg4 db '快速排序',0
msg5 db '堆排序',0
msg6 db '全排列',0
msg7 db '汉诺塔',0
msg8 db '素数环',0
msg9 db '插入排序',0
msg10 db '判定集合元素',0
msg11 db '整数拆分',0
msg12 db '八皇后问题',0
msg13 db '迷宫问题',0
msg14 db '二分查找',0

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