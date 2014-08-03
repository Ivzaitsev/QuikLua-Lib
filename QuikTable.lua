--[[
Quik Table class QTable
]]
QTable ={}
QTable.__index = QTable
function QTable:new()
     -- ������� � ���������������� ��������� ������� QTable
	 local t_id = AllocTable()
     if t_id ~= nil then
         q_table = {}
         setmetatable(q_table, QTable)
         q_table.t_id=t_id
         q_table.caption = ""
         q_table.created = false
		 q_table.curr_col=0
		 q_table.curr_line=0
         --������� � ��������� ���������� ��������
         q_table.columns={}
         return q_table
     else
         return nil
     end
end                
function QTable:Show()
     -- ���������� � ��������� ���� � ��������� ��������
     CreateWindow(self.t_id)
     if self.caption ~="" then
         -- ������ ��������� ��� ����
         SetWindowCaption(self.t_id, self.caption)
     end
     self.created = true
end
function QTable:IsClosed()
     --���� ���� � �������� �������, ���������� �true�
	 return IsWindowClosed(self.t_id)
end
function QTable:delete()
     -- ������� �������
     return DestroyTable(self.t_id)
end
function QTable:GetCaption()
    -- ���������� ������, ���������� ��������� �������
	 if IsWindowClosed(self.t_id) then
         return self.caption
     else
         return GetWindowCaption(self.t_id)
     end
end
function QTable:SetTableNotificationCallback(func)
	if func~=nil and type(func)=='function' then
		return SetTableNotificationCallback(self.t_id,func)
	end
	return false
end
function QTable:SetCaption(s)
     -- ������ ��������� �������
	 self.caption = s
	 if not IsWindowClosed(self.t_id) then
         res = SetWindowCaption(self.t_id, tostring(s))
     end
end
function QTable:AddColumn(name, c_type, width, ff )
    -- �������� �������� ������� name ���� C_type � �������
	-- ff � ������� �������������� ������ ��� �����������
	local col_desc={}
	self.curr_col=self.curr_col+1
    col_desc.c_type = c_type
	col_desc.format_function = ff
    col_desc.id = self.curr_col
	self.columns[name] = col_desc
    -- name ������������ � �������� ��������� �������
    return AddColumn(self.t_id, self.curr_col, name, true, c_type, width)
end 
function QTable:Clear()
     -- �������� �������
     return Clear(self.t_id)
end 
function QTable:SetValue(row, col_name, data)
     -- ���������� �������� � ������
	 local col_ind = self.columns[col_name].id or nil
     if col_ind == nil then
		return false
     end
     -- ���� ��� ������� ������ ������� ��������������, �� ��� ������������
     local ff = self.columns[col_name].format_function
     if type(ff) == "function" then
         -- � �������� ���������� ������������� ������������
         -- ��������� ���������� ������� ��������������
         if self.columns[col_name].c_type==QTABLE_STRING_TYPE or self.columns[col_name].c_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, ff(data))
		else
			return SetCell(self.t_id, row, col_ind, ff(data),data)
		end
     else
		if self.columns[col_name].c_type==QTABLE_STRING_TYPE or self.columns[col_name].c_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, tostring(data))
		else
			return SetCell(self.t_id, row, col_ind, tostring(data),data)
		end
     end
end 
function QTable:AddLine()
    -- ��������� � ����� ������� ������ ������� � ���������� �� �����
	self.curr_line=self.curr_line+1
    return InsertRow(self.t_id, -1)
end
function QTable:DeleteLine(key)
	self.curr_line=self.curr_line-1
	if key==nil then return false end
	return DeleteRow(self.t_id,key)
end
function QTable:GetSize()
     -- ���������� ������ �������, ���������� ����� � ��������
     return GetTableSize(self.t_id)
end
function QTable:GetValue(row, name)
-- �������� ������ �� ������ �� ������ ������ � ����� �������
	 local t={}
	 
	 local col_ind = self.columns[name].id
     if col_ind == nil then
		return nil
     end
	 t = GetCell(self.t_id, row, col_ind)
	 if t then
	    return t["image"]--tostring(t[value])	
	 else 
        return nil
	 end
end
function QTable:GetRow(row)
	 local t={}	 
	 local k,v=0,0
	 for k,v in pairs(self.columns) do
	    local col_ind = self.columns[k].id
        if col_ind == nil then
		    return nil
        end
	    table.insert(t,GetCell(self.t_id, row, col_ind)["image"])
	 end
     return t
end
function QTable:SetPosition(x, y, dx, dy)
     -- ������ ���������� ����
	 -- x,y - ���������� ������ �������� ����; dx,dy - ������ � ������
	 return SetWindowPos(self.t_id, x, y, dx, dy)
end
function QTable:GetPosition()
     -- ������� ���������� ���������� ����
	 local top, left, bottom, right = GetWindowRect(self.t_id)
     return top, left, right-left, bottom-top
end
function QTable:SetSizeSuitable(a,b)
   -- ������� ������ ������ ���� ������� � ������������ � ������� ����������� ������������ �����
   if a==nil then a=42 end
   if b==nil then b=15 end
   local top, left, bottom, right = GetWindowRect(self.t_id)
   self.x, self.y, self.dx, self.dy = top, left, right-left, bottom-top
   self.rows, self.cols = GetTableSize(self.t_id)
   self.dy=a+self.rows*b
   return SetWindowPos(self.t_id, self.x, self.y, self.dx, self.dy)
end
function QTable:SetColor(row,col_name,b_color,f_color,sel_b_color,sel_f_color)
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.SetColor(): No such column name - '..col_name)
			return false
		end
	end
	local bcnum,fcnum,selbcnum,selfcnum=0,0,0,0
	if b_color==nil or b_color=='DEFAULT_COLOR' then bcnum=16777215 else bcnum=RGB2number(b_color) end
	if f_color==nil or f_color=='DEFAULT_COLOR' then fcnum=0 else fcnum=RGB2number(f_color) end
	if sel_b_color==nil or sel_b_color=='DEFAULT_COLOR' then selbcnum=16777215 else selbcnum=RGB2number(sel_b_color) end
	if sel_f_color==nil or sel_f_color=='DEFAULT_COLOR' then selfcnum=0 else selfcnum=RGB2number(sel_f_color) end
	return SetColor(self.t_id,row_ind,col_ind,bcnum,fcnum,selbcnum,selfcnum)
end
function QTable:Highlight(row,col_name,b_color,f_color,timeout)
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.Highlight(): No such column name - '..col_name)
			return false
		end
	end
	local bcnum,fcnum=0,0
	if b_color==nil or b_color=='DEFAULT_COLOR' then bcnum=16777215 else bcnum=RGB2number(b_color) end
	if f_color==nil or f_color=='DEFAULT_COLOR' then fcnum=0 else fcnum=RGB2number(f_color) end
	return Highlight(self.t_id,row_ind,col_ind,bcnum,fcnum,timeout)
end
function QTable:StopHighlight(row,col_name)
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.StopHighlight(): No such column name - '..col_name)
			return false
		end
	end
	return Highlight(self.t_id,row_ind,col_ind,nil,nil,0)
end
function RGB2number(color)
	if type(color)=='number' then return color end
	local i=1
	local a={}
	for cl in color:gmatch('%d+') do
		a[i]=0+cl
		i=i+1
	end
	return RGB(a[1],a[2],a[3])
end