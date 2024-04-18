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
    return cor == "B" and "P" or cor
end

local chars = {"a","b","c","d","e","f","g","h"}
local chars2 = {["a"] = 1, ["b"] = 2, ["c"] = 3, ["d"] = 4, ["e"] = 5, ["f"] = 6, ["g"] = 7, ["h"] = 8}

local game = {
    tabuleiro = {},
    qmjoga = "B",
    startpos = "ra1hb1bc1qd1ke1bf1hg1rh1pa2pb2pc2pd2pe2pf2pg2ph2 ra8hb8bc8qd8ke8bf8hg8rh8pa7pb7pc7pd7pe7pf7pg7ph7 111 111",
    poderoque = {branco = {"1","1","1"}, preto = {"1","1","1"}},
    allmoves = {},
    casas_atacadas = {["B"] = {}, ["P"] = {}},
    pecas = {["B"] = {}, ["P"] = {}},
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
        allmoves = {},
        casas_atacadas = {["B"] = {}, ["P"] = {}},
        pecas = {["B"] = {}, ["P"] = {}},
        cheque = {cordeqm = "", emqm = "", porqm = {}},
    } 
    local tabuleiro = {}
    for j = 1, 8 do
        tabuleiro[chars[j]] = {}
        for i = 1, 8 do
            tabuleiro[chars[j]][i] = {char = " ", cor = "", moves = {}, cravada = false}
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

    updatemoves()
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

function getdiagonais(letra, numero, cor, casas)
    local casas = casas or 7
    local moves = {}
    local tabuleiro = game.tabuleiro
    local inimigo = inimigo(cor)

    local cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --direita cima
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero+crescente] == nil or verificado[numero+crescente].cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=somachar(letra, crescente),numero=numero+crescente})
            end
            local elverificado = verificado[numero+crescente]
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

    for crescente = 1, casas do --direita baixo
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero-crescente] == nil or verificado[numero-crescente].cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=somachar(letra, crescente),numero=numero-crescente})
            end
            local elverificado = verificado[numero-crescente]
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

    for crescente = 1, casas do --esquerda cima
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero+crescente] == nil or verificado[numero+crescente].cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=somachar(letra, -crescente),numero=numero+crescente})
            end
            local elverificado = verificado[numero+crescente]
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

    local cravada = {letra = "", numero = "", pdcrava = true}

    for crescente = 1, casas do --esquerda baixo
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero-crescente] == nil or verificado[numero-crescente].cor == cor then
            break
        else
            if cravada.letra == "" then
                table.insert(moves, {letra=somachar(letra, -crescente),numero=numero-crescente})
            end
            local elverificado = verificado[numero-crescente]
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
        return getvolta(letra, numero, cor, 1)
    elseif char == "p" then
        if cor == "B" then
            return getretas(letra, numero, cor, 1, true)
        else
            return getretas(letra, numero, cor, 1, false, true)
        end
    else
        return {}
    end
end

function updatepecas()
    game.pecas = {["B"] = {}, ["P"] = {}}
    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            game.tabuleiro[i][j].cravada = false
            if k.cor ~= "" then
                if not game.pecas[k.cor][k.char] then game.pecas[k.cor][k.char] = {} end
                table.insert(game.pecas[k.cor][k.char], {letra = i, numero = j})
            end
        end
    end
end

function checkmate()

end

function updatemoves()
    updatepecas()
    game.cheque = {cordeqm = "", emqm = "", porqm = {}}
    game.casas_atacadas = {["B"] = {}, ["P"] = {}}
    game.allmoves = {}
    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            game.tabuleiro[i][j].moves = {}
            if k.cor ~= "" then
                local moves = getmoves(i,j,k.cor,k.char)
                local inimigo = inimigo(k.cor)
                for l, p in pairs(moves) do
                    local target = game.tabuleiro[p.letra][p.numero]
                    local input_command_string = k.char .. i .. j .. " to " .. p.letra .. p.numero
                    game.allmoves[input_command_string] = 1
                    game.casas_atacadas[k.cor][p.letra .. p.numero] = 1
                    game.tabuleiro[i][j].moves[p.letra .. p.numero] = 1
                    if target.char == "h" and target.cor == inimigo then
                        print("CHEQUE")
                        game.cheque.emqm = "k"..game.pecas[inimigo]["k"][1].letra..game.pecas[inimigo]["k"][1].numero
                        game.cheque.cordeqm = inimigo
                        table.insert(game.cheque.porqm, k.char..i..j)
                    end
                end
            end
        end
    end
end

function execmove(movestring)
    if not game.allmoves[movestring] then print("Movimento invalido") return end

    local comando = Split(movestring, " ")

    game.tabuleiro[charat(comando[3], 1)][tonumber(charat(comando[3], 2))] = game.tabuleiro[charat(comando[1], 2)][tonumber(charat(comando[1], 3))]

    game.tabuleiro[charat(comando[1], 2)][tonumber(charat(comando[1], 3))] = {char = " ", cor = "", moves = {}}

    updatemoves()
end

print("\n\n\n\n\n\n\n\n\n\n\n")
setpos(game.startpos)
printtabuleiro()
execmove("pe2 to e3")
execmove("qd1 to h5")
printtabuleiro()
print(game.tabuleiro["f"][7].cravada)
execmove("qh5 to e8")
printtabuleiro()

