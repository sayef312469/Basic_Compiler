#include <bits/stdc++.h>
#pragma once
using namespace std;
class SymbolTable;
struct SymbolInfo
{
    string name, type, code;
    SymbolInfo *next;
    SymbolInfo() : name(""), type(""), code(""), next(NULL) {}
    SymbolInfo(string name, string type) : name(name), type(type), code(""), next(NULL) {}
    string getSymbol()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    inline void getCode(class SymbolTable &st);
    void codeAppend(string one, string two, string three, string op)
    {
        if (op == "+")
        {
            code += "MOV AX, " + one + "\n";
            code += "MOV BX, " + two + "\n";
            code += "ADD AX, BX\n";
            code += "MOV " + three + ", AX\n\n";
        }
        else if (op == "-")
        {
            code += "MOV AX, " + one + "\n";
            code += "MOV BX, " + two + "\n";
            code += "SUB AX, BX\n";
            code += "MOV " + three + ", AX\n\n";
        }
        else if (op == "*")
        {
            code += "MOV AX, " + one + "\n";
            code += "MOV BX, " + two + "\n";
            code += "MUL BX\n";
            code += "MOV " + three + ", AX\n\n";
        }
        else if (op == "/")
        {
            code += "MOV AX, " + one + "\n";
            code += "MOV BX, " + two + "\n";
            code += "DIV BX\n";
            code += "MOV " + three + ", AX\n\n";
        }
        else if (op == "=")
        {
            code += "MOV AX, " + two + "\n";
            code += "MOV " + one + ", AX\n\n";
        }
        else if (op == "||")
        {
            code += "MOV AX, " + one + "\n";
            code += "OR AX, " + two + "\n";
            code += "MOV " + three + ", AX\n\n";
        }
        else if (op == "&&")
        {
            code += "MOV AX, " + one + "\n";
            code += "AND AX, " + two + "\n";
            code += "MOV " + three + ", AX\n\n";
        }
    }
};
class SymbolTable
{
    int sz;
    SymbolInfo **table;

public:
    SymbolTable()
    {
        sz = 10;
        table = new SymbolInfo *[sz];
        for (int i = 0; i < sz; i++)
            table[i] = NULL;
    }
    int getSize()
    {
        return sz;
    }
    int hashFunction(string name)
    {
        return (name[0] * 69) % sz;
    }
    bool Insert(string name, string type)
    {
        pair<int, int> flag = Lookup(name, type);
        if (flag.first != -1)
            return false;
        int index = hashFunction(name);
        SymbolInfo *newitem = new SymbolInfo(name, type);
        if (table[index] == NULL)
            table[index] = newitem;
        else
        {
            SymbolInfo *temp = table[index];
            while (temp->next != NULL)
                temp = temp->next;
            temp->next = newitem;
        }
        return true;
    }
    pair<int, int> Lookup(string name, string type)
    {
        int index = hashFunction(name);
        SymbolInfo *cur = table[index];
        int pos = 0;
        while (cur != NULL)
        {
            if (cur->name == name && cur->type == type)
                return pair<int, int>(index, pos);
            pos++;
            cur = cur->next;
        }
        return pair<int, int>(-1, pos);
    }
    void Delete(string name, string type)
    {
        pair<int, int> flag = Lookup(name, type);
        if (flag.first == -1)
        {
            cout << "Doesn't Exist" << endl;
            // fprintf(out_file, "Doesn't Exist\n");
            return;
        }
        SymbolInfo *cur = table[flag.first];
        SymbolInfo *prev = NULL;
        while (cur != NULL)
        {
            if (cur->name == name)
            {
                if (table[flag.first] == cur)
                    table[flag.first] = table[flag.first]->next;
                else
                    prev->next = cur->next;
                delete cur;
                cout << "Deleted from " << flag.first << " " << flag.second << endl;
                // fprintf(out_file, "Deleted from %d %d\n", flag.first, flag.second);
                return;
            }
            prev = cur;
            cur = cur->next;
        }
    }
    void Print()
    {
        FILE *out_file = fopen("table.txt", "w");
        for (int i = 0; i < sz; i++)
        {
            fprintf(out_file, "%d->", i);
            SymbolInfo *cur = table[i];
            while (cur != NULL)
            {
                if (cur->type == "TempID")
                {
                    cur = cur->next;
                    continue;
                }
                cout << cur->type << " " << cur->name << endl;
                fprintf(out_file, "<%s,%s> ", cur->type.c_str(), cur->name.c_str());
                cout << "Done" << endl;
                cur = cur->next;
            }
            fprintf(out_file, "\n");
        }
        fclose(out_file);
    }
    friend void SymbolInfo::getCode(SymbolTable &st);
};

inline void SymbolInfo::getCode(SymbolTable &st)
{
    code = "MOV AX, @DATA\nMOV DS, AX\n\n" + code;
    code = ".CODE\nMAIN PROC\n\n" + code;
    for (int i = 0; i < st.getSize(); i++)
    {
        SymbolInfo *cur = st.table[i];
        while (cur != NULL)
        {
            if (cur->type == "NUM")
            {
                cur = cur->next;
                continue;
            }
            string p = cur->name + " DW ?\n";
            code = p + code;
            cur = cur->next;
        }
    }
    code = ".MODEL SMALL\n.STACK 1000H\n.DATA\n" + code;
    code += "MAIN ENDP\nEND MAIN\n";
    FILE *out_file = fopen("code.asm", "w");
    fprintf(out_file, "%s", code.c_str());
}
/*int main(){
    SymbolTable m;
    my_file.open("in.txt",ios::in);
    if (!my_file) {
        cout <<"No such file!"<<endl;
    }
    else{
        string tp;
        while (getline(my_file,tp)){
            stringstream ss(tp);
            string a,b[3];
            int i=0;
            while(getline(ss,a,' '))
                b[i++]=a;
            if(b[0][0]=='I')
                m.Insert(b[1],b[2]);
            else if(b[0][0]=='L'){
                pair<int,int> index=m.Lookup(b[1]);
                if(index.first==-1){
                    cout<<"Not Found"<<endl;
                    out_file<<"Not Found"<<endl;
                }
                else{
                    cout<<"Found at "<<index.first<<" "<<index.second<<endl;
                    out_file<<"Found at "<<index.first<<" "<<index.second<<endl;
                }
            }
            else if(b[0][0]=='D')
                m.Delete(b[1]);
            else if(b[0][0]=='P')
                m.Print();
        }
    }
    my_file.close();
    return 0;
}*/
