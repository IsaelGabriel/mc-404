# Laboratório 1
## Objetivo

O objetivo desta atividade é a familiarização com as ferramentas e o ambiente de trabalho da disciplina.

> **Observação**
>
>Nesta disciplina, utilizaremos ferramentas de software (p.ex., o compilador CLANG) que estão instaladas nos computadores do IC-3. Caso você tenha interesse em instalar em seu computador, veja instruções no apêndice do manual da ferramenta ALE


## Geração e Inspeção de Código

### Visão Geral e Processo de Compilação

O processo de compilação de programa em linguagem C envolve 3 etapas principais:

- **Compilação**: Cada arquivo com código na linguagem C (`extensão.c`) é traduzido para código de linguagem de montagem (arquivos com a `extensão .s`).

- **Montagem**: O montador (ou assembler) lê os arquivos em linguagem de montagem e produz um código-objeto (`extensão .o` no Linux). Note que um software complexo pode conter diversos arquivos de código fonte, o que irá levar a vários arquivos-objeto durante o processo de compilação. Assim, apesar de possuir código em linguagem de máquina, os arquivos-objeto não são executáveis, pois o código binário ainda está separado em diversos arquivos-objeto e precisa ser "ligado" em um único arquivo, que contenha todo o código.

-  **Ligação**: O ligador lê diversos arquivos-objeto como entrada, os liga entre si, e também liga código de bibliotecas. O resultado é o executável final, o programa que pode ser executado pelo usuário.

<br>

A figura a seguir ilustra o processo de compilação de um software com dois arquivos fonte: fonte1.c e fonte2.c. Neste diagrama, o comando gcc -S invoca o compilador, o comando as invoca o montador e, por fim, o comando ld invoca o ligador.

![](https://i.imgur.com/WsQ7eCk.png)

### Compilando Código C para Linguagem de Montagem do RISC-V

Por padrão, os compiladores realizam todo o processo de compilação, montagem e ligação do código quando invocados na linha de comando. Para interromper o processo de compilação após a tradução de código C para linguagem de montagem, você deve passar uma flag para o compilador na linha de comando. No caso do `gcc` e do `clang`, esta `flag é -S`. O comando a seguir ilustra como traduzir o código em C do `arquivo prog.c` para linguagem de montagem e salvar o resultado no `arquivo prog.s`.

    clang -S prog.c -o prog.s

Para testar o comando acima, você pode criar um arquivo texto chamando `prog.c` e colocar o seguinte conteúdo:

    /* Programa que retorna a resposta para a Grande Pergunta sobre a 
    * Vida, o Universo e Tudo o Mais */
    int main(void) {
    return 42;
    }

O comando `clang -S prog.c -o prog.s` produzirá código para a linguagem de montagem da máquina nativa, ou seja, para a máquina que está executando o compilador. Se você estiver executando o compilador em um computador com processador Intel ou AMD isso significa que você produzirá código em linguagem de montagem para a família de arquiteturas x86. Como estamos interessados em produzir código para RISC-V, temos que informar ao compilador com flags especiais. No caso do `clang-15`, utilizaremos as flags   `--target=riscv32`, `-march=rv32g` e `-mabi=ilp32d`. Essas flags configuram o compilador para RISC-V de 32 bits. O código abaixo ilustra a compilação do código do `arquivo prog.c` para linguagem de montagem do RISC-V:

    clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax prog.c -S -o prog.s

Você pode verificar o conteúdo do arquivo prog.s (produzido pelo comando acima) abrindo este arquivo em seu editor de texto favorito. Ele é um arquivo texto e contém o mesmo programa que você escreveu em C, porém transcrito para linguagem de montagem para o processador de arquitetura RISC-V RV32. Note que a linguagem de montagem faz referência a instruções (add, mv, etc.) e outros elementos específicos de cada tipo de processador e, consequentemente, é dependente da interface do mesmo.

> **Observação**
>
>Se você comparar o código produzido para a arquitetura nativa e o código produzido para RISC-V RV32 você perceberá que as instruções produzidas pelo compilador são bem diferentes.

### Montando Programas em Linguagem de Montagem

O montador converte o programa em linguagem de montagem para a linguagem de máquina e o armazena em um `arquivo objeto (.o)`. Para invocar diretamente o montador da GNU, o GNU assembler, você pode executar o comando as, como ilustrado a seguir.

> **Observação**
>
> por padrão, o programa as monta programas em linguagem de montagem para a arquitetura nativa. Portanto, se você estiver executando o as em uma máquina que não possui um processador RISC-V para montar um programa em linguagem de montagem para o RISC-V, o montador emitirá um erro.

    as prog.s -o prog.o

Neste caso, o montador armazenará o resultado no arquivo prog.o. Em vez de chamar diretamente o comando as, você pode utilizar o próprio driver do compilador (aplicação gcc, no caso do GCC, e clang, no caso do CLANG) para invocar o montador. Para isso, basta usar o comando que invoca o driver do compilador e passar como parâmetro o arquivo em linguagem de montagem. Por exemplo, para o clang-15, você pode executar:

    clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax prog.s -c -o prog.o

Neste exemplo nós utilizamos a `flag -c` para instruir o driver do compilador a interromper o processo após gerar o arquivo objeto. Se não fizéssemos isso, o driver do compilador tentaria chamar o ligador para gerar o executável final.

Você não deve abrir o arquivo produzido (prog.o) em seu editor de texto, pois é um arquivo binário. Para analisar esse arquivo, você precisa de programas especiais chamados "desmontadores", que interpretam o conteúdo do arquivo e convertem sua representação para texto.

### Gerando Executável a partir de Arquivos Objetos e Bibliotecas

Uma vez que você produziu todos os arquivos objetos do seu programa, como ilustrado na Figura 3.1, você deve juntar todos estes arquivos com as bibliotecas em um único arquivo executável. Este processo, chamado de ligação, é executado pelo ligador. Existem diversas ferramentas que realizam a ligação de arquivos objeto com bibliotecas. O exemplo a seguir mostra como podemos usar a ferramenta `ld.lld` para juntar o conteúdo dos arquivos prog.o, module1.o, e module2.o e produzir o arquivo executável `prog.x`.

    ld.lld prog.o module1.o module2.o -o prog.x

Se o seu program contém apenas um arquivo fonte (p.ex., prog.o), então basta passar este arquivo para o ligador, como ilustrado a seguir:

    ld.lld prog.o -o prog.x

### Desmontando Arquivos Objetos e Executáveis

Arquivos objeto (.o) e arquivos executáveis (.x) são arquivos binários e editores de texto comuns não são capazes de mostrar o seu conteúdo de forma legível. Para analisar esse arquivo, você precisa de programas especiais chamados "desmontadores", que interpretam o conteúdo do arquivo e convertem sua representação para texto. Você pode utilizar o desmontador da GNU, a ferramenta objdump, ou a ferramenta llvm-objdump para desmontar o arquivo binário e mostrar suas informações de forma textual. Para isso, basta executar o comando:

    llvm-objdump -D prog.o

Tente comparar a saída produzida pelo desmontador (`llvm-objdump`) com o arquivo com o programa em linguagem de montagem usado durante o processo de montagem (prog.s). Você perceberá que eles são diferentes, mas possuem diversas informações em comum (p.ex., listas de instruções a serem executadas pelo processador).

### Automatizando o Processo de Geração de Código com Makefiles

O processo de desenvolvimento de software envolve diversas iterações de correções de bugs e recompilações. Entretanto, muitos destes projetos possuem uma quantidade grande de arquivos com código fonte e a compilação de todos os arquivos é um processo lento. Os arquivos objeto (.o) precisam ser ligados novamente para formar o novo binário, no entanto, apenas os arquivos modificados precisam ser recompilados. Dessa forma é importante ter um mecanismo automático para recompilar apenas os arquivos necessários. Para isso, existe uma modalidade de script específica para automatizar a compilação de softwares. O GNU Makefile é um exemplo largamente utilizado no mundo GNU/Linux. Para instalá-lo em uma distribuição baseada no Debian, você pode executar o seguinte comando:

    sudo apt-get install build-essential

Para fazer o seu próprio script que irá orientar o GNU Make a construir o seu programa, você deve criar um arquivo texto chamado Makefile, que deve estar na mesma pasta dos códigos-fonte, contendo regras para a criação de cada arquivo. Por exemplo, você pode criar regras para especificar como o arquivo.s (em linguagem de montagem) é criado (utilizando o compilador clang), especificar como os arquivos-objeto .o (códigos-objeto) são criados (utilizando o montador) e assim em diante. Exemplo de criação de regras:

    ola.s: ola.c
        clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax ola.c -S -o ola.s

    ola.o: ola.s
        clang-15 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax ola.s -c -o ola.o

Neste exemplo existem duas regras, nomeadas ola.o e ola.s. O nome da regra deve corresponder ao arquivo que é produzido pela regra seguido do caractere ":". Por exemplo, a regra que produz o arquivo ola.o deve ser nomeada "ola.o:". Os arquivos necessários para produzir o arquivo ola.o devem aparecer em uma lista (separada por espaços) após o caractere ":" (no nosso caso, ola.s é necessário para criar ola.o). Em seguida, você deve, na linha seguinte, usar uma tabulação (apertar a tecla tab) e digitar o comando que será executado no shell para produzir esse arquivo. No nosso exemplo, chamamos o compilador clang-15 para traduzir um arquivo em linguagem C para linguagem de montagem, e em outra regra, chamamos o montador para transformar um arquivo em linguagem de montagem .s em um arquivo-objeto .o. Note que você pode especificar como arquivo de entrada de uma regra o nome de outra regra, e esta outra regra será chamada antes para produzir o arquivo de entrada necessário.

> **Atenção**
>
> O script não funcionará se não houver uma tabulação (tab) antes dos comandos "clang-15 ..."! Não use espaços! Além disso, note que alguns editores de texto incluem espaços em vez do caracteres de tabulação quando a tecla tab é pressionada.

Você pode criar várias regras em um mesmo arquivo Makefile. Para executar o script, na linha de comando, digite make nome-da-regra. Por exemplo:

    make ola.o

O programa make irá executar os comandos associados à regra ola.o, descrita no Makefile. Note que o programa make sempre lê o arquivo de nome Makefile na pasta em que você está e o usa como script. Se você não utilizar esse nome de arquivo (Makefile com "M" maiúsculo), o script irá falhar. Se você invocar o comando make sem parâmetros ele executará a primeira regra do arquivo Makefile.

## Exercícios

### 1 - Compilar um Programa com Múltiplos Arquivos Passo a Passo

Realize o processo de compilação do programa a seguir passo a passo, ou seja, gerando o código em linguagem de montagem e depois o código objeto para cada arquivo fonte e, por fim, chamando o ligador para juntar todos os arquivos objetos e produzir o arquivo executável prog.x. Você deve utilizar o compilador clang-15 e gerar código para a arquitetura RISC-V R32, como ilustrado nas seções anteriores.

O programa é composto por dois arquivos: arquivo1.c e arquivo2.c. O conteúdo dos arquivos é apresentado abaixo.

    extern void write(int __fd, const void *__buf, int __n);
    int main(void) {
    const char str[] = "Hello World!\n";
    write(1, str, 13);
    return 0;
    }

    void _start(){
    main();
    }

<br>

    void write(int __fd, const void *__buf, int __n){
    __asm__ __volatile__(
        "mv a0, %0           # file descriptor\n"
        "mv a1, %1           # buffer \n"
        "mv a2, %2           # size \n"
        "li a7, 64           # syscall write (64) \n"
        "ecall"
        :   // Output list
        :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
        : "a0", "a1", "a2", "a7"
    );
    }

Para realizar esta atividade, você deve, primeiramente, criar estes dois arquivos (com seus respectivos conteúdos) em uma pasta (diretório) em seu computador.

> **Dica**
>
> Você pode utilizar o desmontador para inspecionar o conteúdo do arquivo executável. Você perceberá que ele contém a sequência de instruções da função write (do arquivo2.c) e os nomes das funções main, _start e write.

### 2 - Produzir um Makefile para Automatizar os Passos do Exercício Anterior

Neste exercício, você deve produzir um script Makefile que automatiza o processo de compilação realizado manualmente no exercício anterior, ou seja, para um programa que contém dois arquivos fonte (arquivo1.c e arquivo2.c). O arquivo final a ser produzido deve se chamar prog.x. Para isso, você deve criar uma regra para cada arquivo intermediário, até chegar no arquivo final. Você pode testar seu script Makefile executando os seguintes comandos:

    make arquivo1.s
    make arquivo2.s
    make arquivo1.o
    make arquivo2.o
    make prog.x

Elas devem gerar, respectivamente: o código em linguagem de montagem do arquivo1 e do arquivo2; o objeto do arquivo1 e do arquivo2; o executável final.