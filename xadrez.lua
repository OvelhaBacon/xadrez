function printtable(table)
    if type(table) ~= "table" then
        print("isso n e uma tabela :D")
        return
    end
    print("------------------")
    for i, v in pairs(table) do
        print(tostring(i) .. " = " .. tostring(v))
    end
    print("------------------")
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result;
end

function booltoint(bool)
    return bool and 1 or 0
end

function inimigo(cor)
    return cor == "B" and "P" or "B"
end

function insertable(table1, table2)
    for i, v in pairs(table2) do
        table.insert(table1, v)
    end
    return table1
end

local chars = {"a","b","c","d","e","f","g","h"}
local chars2 = {["a"] = 1, ["b"] = 2, ["c"] = 3, ["d"] = 4, ["e"] = 5, ["f"] = 6, ["g"] = 7, ["h"] = 8}

local game = {
    tabuleiro = {},
    qmjoga = "B",
    startpos = "ra1hb1bc1qd1ke1bf1hg1rh1pa2pb2pc2pd2pe2pf2pg2ph2 ra8hb8bc8qd8ke8bf8hg8rh8pa7pb7pc7pd7pe7pf7pg7ph7 111 111",
    poderoque = {branco = {"1","1","1"}, preto = {"1","1","1"}},
    allmoves = {["B"] = {}, ["P"] = {}},
    casas_atacadas = {["B"] = {}, ["P"] = {}},
    cheque = {cordeqm = "", emqm = "", porqm = {}},
}

function printtabuleiro()
    print("--------------------------------")
    if game.tabuleiro["a"] == nil then return end
    for j = 8, 1, -1 do
        local linha = ""
        for i = 1, 8 do
            linha = linha .. game.tabuleiro[chars[i]][j].char .. " "
        end
        print(linha)
    end
    print("--------------------------------")
end

function reset_tabuleiro()
    game = {
        tabuleiro = {},
        qmjoga = "B",
        startpos = "ra1hb1bc1qd1ke1bf1hg1rh1pa2pb2pc2pd2pe2pf2pg2ph2 ra8hb8bc8qd8ke8bf8hg8rh8pa7pb7pc7pd7pe7pf7pg7ph7 111 111",
        poderoque = {branco = {"1","1","1"}, preto = {"1","1","1"}},
        allmoves = {["B"] = {}, ["P"] = {}},
        casas_atacadas = {["B"] = {}, ["P"] = {}},
        cheque = {cordeqm = "", emqm = "", porqm = {}},
    }
    local tabuleiro = {}
    for j = 1, 8 do
        tabuleiro[chars[j]] = {}
        for i = 1, 8 do
            tabuleiro[chars[j]][i] = {char = " ", cor = "", cravada = false}
        end
    end
    game.tabuleiro = tabuleiro
end

function charat(string, lugar)
    return string:sub(lugar,lugar)
end

function setpos(pos)
    reset_tabuleiro()
    local lados = Split(pos, " ")

    local brancas = lados[1]
    for i = 1, #brancas/3 do
        local reali = i*3-2
        game.tabuleiro[charat(brancas, reali+1)][tonumber(charat(brancas, reali+2))] = {char = charat(brancas, reali), cor = "B"}
    end

    local pretas = lados[2]
    for i = 1, #pretas/3 do
        local reali = i*3-2
        game.tabuleiro[charat(pretas, reali+1)][tonumber(charat(pretas, reali+2))] = {char = charat(pretas, reali), cor ="P"}
    end

    local poderoqueB = lados[3]
    local poderoqueP = lados[4]
    game.poderoque = {branco = {charat(poderoqueB, 1),charat(poderoqueB, 2),charat(poderoqueB, 3)}, preto = {charat(poderoqueP, 1),charat(poderoqueP, 2),charat(poderoqueP, 3)}}

    updatepecas()
end

function getpos()
    local lados = {branco = "", preto = ""}
    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            if k.cor ~= "" then
                if k.cor == "B" then
                    lados.branco = lados.branco .. k.char .. i .. j
                else
                    lados.preto = lados.preto .. k.char .. i .. j
                end
            end
        end
    end
    local stringe = lados.branco .. " " .. lados.preto .. " "

    for i = 1, 3 do
        stringe = stringe .. game.poderoque.branco[i]
    end

    stringe = stringe .. " "

    for i = 1, 3 do
        stringe = stringe .. game.poderoque.preto[i]
    end

    return stringe
end

function somachar(char, soma)
    local atual = chars2[char]
    return chars[atual+soma]
end

function getretas(letra, numero, cor, casas, socima, sobaixo)
    local casas = casas or 7
    if socima or sobaixo then
        if numero == 7 or numero == 2 then
            casas = 2
        end
    end
    local moves = {}
    local tabuleiro = game.tabuleiro
    local inimigo = inimigo(cor)
    
    local cravada = {letra = "", numero = "", pdcrava = true}

    if sobaixo then goto baixo end

    for crescente = 1, casas do --cima
        local verificado = tabuleiro[letra][numero+crescente]
        if verificado == nil or verificado.cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=letra,numero=numero+crescente})
            end
            local elverificado = verificado
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = letra
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    if socima then return moves end

    ::baixo::

    local cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --baixo
        local verificado = tabuleiro[letra][numero-crescente]
        if verificado == nil or verificado.cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=letra,numero=numero-crescente})
            end
            local elverificado = verificado
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = letra
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    if sobaixo then return moves end
    
    local cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --direita
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero].cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=somachar(letra, crescente),numero=numero})
            end
            local elverificado = verificado[numero]
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = somachar(letra, crescente)
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    local cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --esquerda
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero].cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=somachar(letra, -crescente),numero=numero})
            end
            local elverificado = verificado[numero]
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = somachar(letra, -crescente)
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    return moves
end

function getdiagonais(letra, numero, cor, casas, peao, socima, sobaixo)
    local casas = casas or 7
    local moves = {}
    local tabuleiro = game.tabuleiro
    local inimigo = inimigo(cor)

    local cravada = {letra = "", numero = "", pdcrava = true}

    if sobaixo then goto baixo end

    for crescente = 1, casas do --direita cima
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero+crescente] == nil or verificado[numero+crescente].cor == cor then
            break
        else
            local elverificado = verificado[numero+crescente]
            if cravada.letra == "" and ((not peao) or elverificado.cor == inimigo) then
                table.insert(moves, {letra=somachar(letra, crescente),numero=numero+crescente})
            end
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = somachar(letra, crescente)
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --esquerda cima
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero+crescente] == nil or verificado[numero+crescente].cor == cor then
            break
        else
            local elverificado = verificado[numero+crescente]
            if cravada.letra == "" and ((not peao) or elverificado.cor == inimigo) then
                table.insert(moves, {letra=somachar(letra, -crescente),numero=numero+crescente})
            end
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = somachar(letra, -crescente)
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    if socima then return moves end

    ::baixo::

    cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --direita baixo
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero-crescente] == nil or verificado[numero-crescente].cor == cor then
            break
        else
            local elverificado = verificado[numero-crescente]
            if cravada.letra == "" and ((not peao) or elverificado.cor == inimigo) then
                table.insert(moves, {letra=somachar(letra, crescente),numero=numero-crescente})
            end
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = somachar(letra, crescente)
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --esquerda baixo
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero-crescente] == nil or verificado[numero-crescente].cor == cor then
            break
        else
            local elverificado = verificado[numero-crescente]
            if cravada.letra == "" and ((not peao) or elverificado.cor == inimigo) then
                table.insert(moves, {letra=somachar(letra, -crescente),numero=numero-crescente})
            end
            if elverificado.cor == inimigo then
                if elverificado.char == "k" then
                    if cravada.letra ~= "" and cravada.pdcrava then
                        game.tabuleiro[cravada.letra][cravada.numero].cravada = true
                    end
                    break
                else
                    if cravada.letra ~= "" then cravada.pdcrava = false end
                    cravada.letra = somachar(letra, -crescente)
                    cravada.numero = numero+crescente
                end
            end
        end
    end

    return moves
end

function getvolta(letra, numero, cor, casas)
    local casas = casas or 7
    local moves = {}
    for i, v in pairs(getretas(letra, numero, cor, casas)) do
        table.insert(moves, v)
    end
    for i, v in pairs(getdiagonais(letra, numero, cor, casas)) do
        table.insert(moves, v)
    end
    return moves
end

function getls(letra, numero, cor)
    local moves = {}
    local tabuleiro = game.tabuleiro

    local loc = game.tabuleiro[letra][numero]

    local direita = game.tabuleiro[somachar(letra, 2)]
    if direita then
        if direita[numero+1] and direita[numero+1].cor ~= cor then table.insert(moves, {letra = somachar(letra, 2), numero = numero+1}) end
        if direita[numero-1] and direita[numero-1].cor ~= cor then table.insert(moves, {letra = somachar(letra, 2), numero = numero-1}) end
    end

    local esquerda = game.tabuleiro[somachar(letra, -2)]
    if esquerda then
        if esquerda[numero+1] and esquerda[numero+1].cor ~= cor then table.insert(moves, {letra = somachar(letra, -2), numero = numero+1}) end
        if esquerda[numero-1] and esquerda[numero-1].cor ~= cor then table.insert(moves, {letra = somachar(letra, -2), numero = numero-1}) end
    end

    local baixo = game.tabuleiro[letra][numero-2]
    if baixo then
        if game.tabuleiro[somachar(letra, 1)] and game.tabuleiro[somachar(letra, 1)][numero-2].cor ~= cor then table.insert(moves, {letra = somachar(letra, 1), numero = numero-2}) end
        if game.tabuleiro[somachar(letra, -1)] and game.tabuleiro[somachar(letra, -1)][numero-2].cor ~= cor then table.insert(moves, {letra = somachar(letra, -1), numero = numero-2}) end
    end

    local cima = game.tabuleiro[letra][numero+2]
    if cima then
        if game.tabuleiro[somachar(letra, 1)] and game.tabuleiro[somachar(letra, 1)][numero+2].cor ~= cor then table.insert(moves, {letra = somachar(letra, 1), numero = numero+2}) end
        if game.tabuleiro[somachar(letra, -1)] and game.tabuleiro[somachar(letra, -1)][numero+2].cor ~= cor then table.insert(moves, {letra = somachar(letra, -1), numero = numero+2}) end
    end

    return moves
end

function getmoves(letra, numero, cor, char)
    local moves = {}
    if char == "h" then
        return getls(letra, numero, cor)
    elseif char == "r" then
        return getretas(letra, numero, cor)
    elseif char == "b" then
        return getdiagonais(letra, numero, cor)
    elseif char == "q" then
        return getvolta(letra, numero, cor)
    elseif char == "k" then
        local inimigo = inimigo(cor)
        for i, v in pairs(getvolta(letra, numero, cor, 1)) do
            if not game.casas_atacadas[inimigo][v.letra..v.numero] then
                table.insert(moves, v)
            end
        end
        return moves
    elseif char == "p" then
        if cor == "B" then
            moves = insertable(moves, getdiagonais(letra, numero, cor, 1, true, true, false))
            moves = insertable(moves, getretas(letra, numero, cor, 1, true))
            return moves
        else
            moves = insertable(moves, getdiagonais(letra, numero, cor, 1, true, false, true))
            moves = insertable(moves, getretas(letra, numero, cor, 1, false, true))
            return moves
        end
    else
        return {}
    end
end

function getataques(letra, numero, cor, char)
    if char == "p" then
        return getdiagonais(letra, numero, cor, 1, false, cor == "P")
    elseif char == "k" then
        return getvolta(letra, numero, cor, 1)
    else
        return getmoves(letra, numero, cor, char)
    end
end

function updateataques()
    game.cheque = {cordeqm = "", emqm = "", porqm = {}}
    game.casas_atacadas = {["B"] = {}, ["P"] = {}}

    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            if k.cor ~= "" then
                local ataques = getataques(i, j, k.cor, k.char)
                for l, p in pairs(ataques) do
                    game.casas_atacadas[k.cor][p.letra..p.numero] = 1
                    if game.tabuleiro[p.letra][p.numero].char == "k" then
                        game.cheque.cordeqm = inimigo(k.cor)
                        game.cheque.emqm = "k"..p.letra..p.numero
                        game.cheque.porqm = k.char..i..j
                        table.insert(game.cheque.porqm, k.char..i..j)
                    end
                end
            end
        end
    end
end

function updatemoves()
    game.allmoves = {["B"] = {}, ["P"] = {}}

    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            if k.cor ~= "" then
                local moves = getmoves(i, j, k.cor, k.char)
                for l, p in pairs(moves) do
                    local string_command = k.char..i..j .. " to " .. p.letra..p.numero
                    game.allmoves[k.cor][string_command] = 1
                end
            end
        end
    end
end

function updatepecas()
    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            if k.cor ~= "" then
                game.tabuleiro[i][j].cravada = false
            end
        end
    end
    updateataques()
    updatemoves()
end

function execmove(movestring)
    if not game.allmoves[game.qmjoga][movestring] then print("Movimento invalido") return end

    local comando = Split(movestring, " ")

    game.tabuleiro[charat(comando[3], 1)][tonumber(charat(comando[3], 2))] = game.tabuleiro[charat(comando[1], 2)][tonumber(charat(comando[1], 3))]

    game.tabuleiro[charat(comando[1], 2)][tonumber(charat(comando[1], 3))] = {char = " ", cor = "", moves = {}}

    game.qmjoga = inimigo(game.qmjoga)

    updatepecas()
end

print("\n\n\n\n\n\n\n\n\n\n\n")
setpos(game.startpos)
printtabuleiro()
execmove("pe2 to e3")
execmove("pd7 to d6")
execmove("qd1 to g4")
execmove("ke8 to d7")
execmove("pe7 to e6")
execmove("pa2 to a3")
execmove("ke8 to d7")
execmove("pb2 to b4")
execmove("pd6 to d5")
printtabuleiro()

