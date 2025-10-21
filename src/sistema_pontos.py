from __future__ import annotations
import os
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Set, Tuple

# ---------------- CONFIGURAÇÃO ----------------
FIXO_FIM = "003"
NOME_ARQUIVO = Path('moviment.txt')
NUM_PONTOS_ESPERADOS = 4
TAMANHO_LINHA = 23
VERSAO = "1.0"
# ----------------------------------------------

# ---------- UTILITÁRIOS ----------
def formatar_data_para_ddmmYYYY(data_str: str) -> str:
    s = data_str.strip().replace("/", "")
    if len(s) == 8:
        return f"{s[:2]}/{s[2:4]}/{s[4:]}"
    return data_str.strip()

def decompor_data(data_str: str) -> Tuple[str, str, str]:
    data = formatar_data_para_ddmmYYYY(data_str)
    return data[:2], data[3:5], data[6:10]

def formatar_horario(h: str) -> str:
    h2 = h.strip()
    if not h2:
        return h2
    return h2.zfill(4)

def validar_horario(ponto: str) -> bool:
    p = formatar_horario(ponto)
    if len(p) == 4 and p.isdigit():
        hh, mm = int(p[:2]), int(p[2:])
        return 0 <= hh <= 23 and 0 <= mm <= 59
    return False
# ------------------------------------------------

# ---------- CLASSE REGISTRO PONTO ----------
class RegistroPonto:
    def __init__(self, cracha: str):
        self.cracha = cracha
        self.pontos: Dict[str, List[str]] = {}

    def adicionar_ponto(self, data: str, horario: str):
        data = formatar_data_para_ddmmYYYY(data)
        horario = formatar_horario(horario)
        self.pontos.setdefault(data, [])
        if horario not in self.pontos[data]:
            self.pontos[data].append(horario)

    def remover_ponto(self, data: str, horario: str):
        horario = formatar_horario(horario)
        if data in self.pontos and horario in self.pontos[data]:
            self.pontos[data].remove(horario)

    def resumo_problemas(self) -> Dict[str, str]:
        problemas = {}
        for data, horarios in self.pontos.items():
            qtd = len(horarios)
            if qtd != NUM_PONTOS_ESPERADOS:
                problemas[data] = "FALTANDO" if qtd < NUM_PONTOS_ESPERADOS else "EXCESSO"
        return problemas

    def gerar_linhas(self, data: str, horarios: List[str]) -> List[str]:
        dd, mm, yyyy = decompor_data(data)
        ano_short = yyyy[-2:].zfill(2)
        return [f"{self.cracha}{dd}{mm}{ano_short}{formatar_horario(h)}{FIXO_FIM}" for h in horarios]
# ------------------------------------------------

# ---------- I/O DE ARQUIVO ----------
def importar_moviment(nome_arquivo: Path) -> Tuple[Dict[str, RegistroPonto], Set[str]]:
    registros: Dict[str, RegistroPonto] = {}
    todas_linhas_existentes: Set[str] = set()
    if not nome_arquivo.exists():
        return registros, todas_linhas_existentes

    with open(nome_arquivo, 'r', encoding='utf-8') as f:
        for linha in f:
            linha = linha.strip()
            if len(linha) != TAMANHO_LINHA:
                continue
            todas_linhas_existentes.add(linha)
            cracha = linha[:10]
            dia = linha[10:12]
            mes = linha[12:14]
            ano = linha[14:16]
            horario = linha[16:20]
            data = f"{dia}/{mes}/20{ano}"

            if cracha not in registros:
                registros[cracha] = RegistroPonto(cracha)
            registros[cracha].adicionar_ponto(data, horario)
    return registros, todas_linhas_existentes

def gravar_linhas(novas_linhas: List[str], todas_linhas_existentes: Set[str]) -> Tuple[int, List[str]]:
    adicionadas: List[str] = []
    if not novas_linhas:
        return 0, adicionadas

    NOME_ARQUIVO.parent.mkdir(parents=True, exist_ok=True)
    try:
        with open(NOME_ARQUIVO, 'a', encoding='utf-8') as f:
            for l in novas_linhas:
                if l not in todas_linhas_existentes:
                    f.write(l + '\n')
                    todas_linhas_existentes.add(l)
                    adicionadas.append(l)
            f.flush()
            os.fsync(f.fileno())
    except Exception as e:
        print(f"Erro ao gravar no arquivo: {e}")
    return len(adicionadas), adicionadas
# ------------------------------------------------

# ---------- FUNÇÕES DE UI ----------
def listar_crachas(registros: Dict[str, RegistroPonto]) -> List[str]:
    if not registros:
        print("[INFO] Nenhum crachá carregado.")
        return []
    print("\n--- Crachás disponíveis ---")
    for c in sorted(registros.keys()):
        print(c)
    return list(registros.keys())

def mostrar_conteudo_arquivo():
    if NOME_ARQUIVO.exists():
        print("\n--- CONTEÚDO DO ARQUIVO ---")
        with open(NOME_ARQUIVO, 'r', encoding='utf-8') as f:
            linhas = f.readlines()
            if linhas:
                for i, l in enumerate(linhas, 1):
                    print(f"{i:03d}: {l.strip()}")
            else:
                print("[INFO] O arquivo está vazio.")
    else:
        print(f"[INFO] Arquivo '{NOME_ARQUIVO}' não existe.")
# ------------------------------------------------

def menu() -> str:
    print("\n=== MENU PRINCIPAL ===")
    print("1 - Corrigir automaticamente pontos faltantes/excedentes")
    print("2 - Visualizar pontos de um crachá")
    print("3 - Visualizar arquivo")
    print("4 - Relatório mensal completo")
    print("5 - Duplicar dias existentes")
    print("6 - Adicionar registros manualmente")
    print("7 - Listar crachás")
    print("8 - Sair")
    return input("Escolha uma opção: ").strip()
# ------------------------------------------------

# ---------- FUNÇÕES PRINCIPAIS ----------
def corrigir_automatico(registros: Dict[str, RegistroPonto], todas_linhas_existentes: Set[str]):
    listar_crachas(registros)
    cracha = input("\nDigite o CRAchá para correção: ").strip().zfill(10)
    if cracha not in registros:
        print("Crachá não encontrado.")
        return

    registro = registros[cracha]
    problemas = registro.resumo_problemas()
    if not problemas:
        print("Nenhum problema encontrado para este crachá.")
        return

    novas_linhas: List[str] = []
    for data, tipo in problemas.items():
        horarios = registro.pontos.get(data, [])
        print(f"\nCorrigindo {data} ({tipo}) - existentes: {', '.join(sorted(horarios)) if horarios else 'nenhum'}")

        if tipo == "FALTANDO":
            while len(horarios) < NUM_PONTOS_ESPERADOS:
                ponto = input("Digite o horário a adicionar (HHMM) ou ENTER para pular: ").strip()
                if not ponto:
                    break
                if validar_horario(ponto) and formatar_horario(ponto) not in horarios:
                    h = formatar_horario(ponto)
                    horarios.append(h)
                    novas_linhas.extend(registro.gerar_linhas(data, [h]))
                    print(f"Ponto {h} adicionado.")
                else:
                    print("Horário inválido ou já existente.")

        elif tipo == "EXCESSO":
            while len(horarios) > NUM_PONTOS_ESPERADOS:
                ponto = input("Digite o horário a remover (HHMM) ou ENTER para pular: ").strip()
                if not ponto:
                    break
                h = formatar_horario(ponto)
                if h in horarios:
                    horarios.remove(h)
                    print(f"Ponto {h} removido.")
                else:
                    print("Horário não encontrado neste dia.")

    added_count, _ = gravar_linhas(novas_linhas, todas_linhas_existentes)
    if added_count:
        print(f"\n[SUCESSO] {added_count} linha(s) adicionada(s) ao arquivo.")
    else:
        print("\nNenhuma linha nova gravada.")

def visualizar_cracha(registros: Dict[str, RegistroPonto]):
    listar_crachas(registros)
    cracha = input("\nDigite o CRAchá: ").strip().zfill(10)
    if cracha in registros:
        registro = registros[cracha]
        for data, horarios in sorted(registro.pontos.items(), key=lambda x: datetime.strptime(x[0], "%d/%m/%Y")):
            print(f"{data}: {len(horarios)} ponto(s) -> {', '.join(sorted(horarios))}")
    else:
        print("Crachá não encontrado.")

def gerar_relatorio_mensal(registros: Dict[str, RegistroPonto]):
    listar_crachas(registros)
    cracha = input("\nDigite o CRAchá: ").strip().zfill(10)
    if cracha not in registros:
        print("Crachá não encontrado.")
        return

    registro = registros[cracha]
    datas = sorted(registro.pontos.keys(), key=lambda x: datetime.strptime(x, "%d/%m/%Y"))
    if not datas:
        print("Nenhum registro encontrado.")
        return

    inicio = datetime.strptime(datas[0], "%d/%m/%Y")
    fim = datetime.strptime(datas[-1], "%d/%m/%Y")
    atual = inicio

    print(f"\n--- RELATÓRIO MENSAL ({inicio.strftime('%d/%m/%Y')} até {fim.strftime('%d/%m/%Y')}) ---")
    while atual <= fim:
        data_str = atual.strftime("%d/%m/%Y")
        if data_str in registro.pontos:
            qtd = len(registro.pontos[data_str])
            status = "OK" if qtd == NUM_PONTOS_ESPERADOS else ("FALTANDO" if qtd < NUM_PONTOS_ESPERADOS else "EXCESSO")
            print(f"{data_str}: {qtd} ponto(s) - {status}")
        else:
            print(f"{data_str}: sem registro")
        atual += timedelta(days=1)

def duplicar_dia(registros: Dict[str, RegistroPonto], todas_linhas_existentes: Set[str]):
    listar_crachas(registros)
    cracha = input("\nDigite o CRAchá: ").strip().zfill(10)
    if cracha not in registros:
        print("Crachá não encontrado.")
        return

    registro = registros[cracha]
    data_origem_raw = input("Data de origem (DD/MM/AAAA): ").strip()
    data_origem = formatar_data_para_ddmmYYYY(data_origem_raw)
    if data_origem not in registro.pontos:
        print("Data de origem não encontrada.")
        return

    destino_input = input("Datas destino (DD/MM/AAAA), separadas por vírgula: ").strip()
    if not destino_input:
        print("Nenhuma data destino informada.")
        return

    destinos = [formatar_data_para_ddmmYYYY(d.strip()) for d in destino_input.split(",") if d.strip()]
    horarios = registro.pontos[data_origem]

    total_adicionados = 0
    for data_dest in destinos:
        try:
            datetime.strptime(data_dest, "%d/%m/%Y")
        except ValueError:
            print(f"Formato inválido: {data_dest} — pulando.")
            continue

        if data_dest in registro.pontos:
            print(f"{data_dest}: já possui registros — pulando.")
            continue

        novas_linhas = registro.gerar_linhas(data_dest, horarios)
        _, adicionadas = gravar_linhas(novas_linhas, todas_linhas_existentes)
        if adicionadas:
            registro.pontos[data_dest] = list(horarios)
            total_adicionados += len(adicionadas)
            print(f"{len(adicionadas)} ponto(s) duplicado(s) para {data_dest}.")

    print(f"\nDuplicação concluída. Total de {total_adicionados} linha(s) adicionada(s).")

def adicionar_manual(registros: Dict[str, RegistroPonto], todas_linhas_existentes: Set[str]):
    print("\n--- ADICIONAR REGISTROS MANUALMENTE ---")
    cracha = input("Digite o CRAchá: ").strip().zfill(10)
    data_raw = input("Digite a data (DD/MM/AAAA): ").strip()
    horarios_raw = input("Digite horários separados por vírgula (ex: 0800,1200,1300,1800): ").strip()

    if not (cracha and data_raw and horarios_raw):
        print("Dados insuficientes para adicionar registro.")
        return

    data = formatar_data_para_ddmmYYYY(data_raw)
    lista_horarios = [formatar_horario(h) for h in horarios_raw.split(",") if validar_horario(h)]
    if not lista_horarios:
        print("Nenhum horário válido informado.")
        return

    if cracha not in registros:
        registros[cracha] = RegistroPonto(cracha)
    registro = registros[cracha]

    novas_linhas = registro.gerar_linhas(data, lista_horarios)
    _, adicionadas = gravar_linhas(novas_linhas, todas_linhas_existentes)
    if adicionadas:
        registro.pontos.setdefault(data, [])
        for h in lista_horarios:
            if h not in registro.pontos[data]:
                registro.pontos[data].append(h)
        print(f"\n{len(adicionadas)} ponto(s) adicionados para {data}.")
    else:
        print("Todos os registros informados já existem no arquivo.")

# ---------- FUNÇÃO MAIN ----------
def main():
    print("====================================")
    print(f" SISTEMA DE PONTOS AUTOMÁTICO v{VERSAO} ")
    print("====================================")
    print(f"\nArquivo sendo usado: {NOME_ARQUIVO.resolve()}\n")

    registros, todas_linhas_existentes = importar_moviment(NOME_ARQUIVO)

    while True:
        opcao = menu()
        if opcao == '1':
            corrigir_automatico(registros, todas_linhas_existentes)
        elif opcao == '2':
            visualizar_cracha(registros)
        elif opcao == '3':
            mostrar_conteudo_arquivo()
        elif opcao == '4':
            gerar_relatorio_mensal(registros)
        elif opcao == '5':
            duplicar_dia(registros, todas_linhas_existentes)
        elif opcao == '6':
            adicionar_manual(registros, todas_linhas_existentes)
        elif opcao == '7':
            listar_crachas(registros)
        elif opcao == '8':
            break
        else:
            print("Opção inválida. Tente novamente.")

    print("\nProcesso finalizado.")

if __name__ == "__main__":
    main()
