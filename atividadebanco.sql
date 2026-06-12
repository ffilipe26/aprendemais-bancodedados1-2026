CREATE TABLE Professor (

   ID_PROFESSOR  INTEGER      PRIMARY KEY AUTOINCREMENT,

   CPF           CHAR(11)     NOT NULL UNIQUE,

   NOME          VARCHAR(100) NOT NULL,

   EMAIL         VARCHAR(100),

   TELEFONE      VARCHAR(15)

);
 
CREATE TABLE Instituicao (

   CNPJ          CHAR(14)     PRIMARY KEY,

   NOME          VARCHAR(150) NOT NULL,

   LOCALIZACAO   VARCHAR(255),

   EMAIL         VARCHAR(100),

   TELEFONE      VARCHAR(15)

);
 
CREATE TABLE Aluno (

   RA            VARCHAR(20)  PRIMARY KEY,

   CPF           CHAR(11)     NOT NULL UNIQUE,

   NOME          VARCHAR(100) NOT NULL,

   EMAIL         VARCHAR(100),

   TELEFONE      VARCHAR(15)

);
 
CREATE TABLE Disciplina (

   CD_DISCIPLINA INTEGER      PRIMARY KEY AUTOINCREMENT,

   NOME          VARCHAR(100) NOT NULL,

   ID_PROFESSOR  INT          NOT NULL,

   FOREIGN KEY (ID_PROFESSOR) REFERENCES Professor(ID_PROFESSOR)

);
 
CREATE TABLE RelatorioIA (

   ID_RELATORIO  INTEGER PRIMARY KEY AUTOINCREMENT,

   RA_ALUNO      VARCHAR(20),

   DATA          DATE,

   CD_DISCIPLINA INT,

   PONTUACAO     REAL DEFAULT 0.0,

   FOREIGN KEY (RA_ALUNO)      REFERENCES Aluno(RA),

   FOREIGN KEY (CD_DISCIPLINA) REFERENCES Disciplina(CD_DISCIPLINA)

);
 
CREATE TABLE Atividade (

   ID_ATVD       INTEGER PRIMARY KEY AUTOINCREMENT,

   CD_DISCIPLINA INT  NOT NULL,

   ID_RELATORIO  INT,

   ID_PROFESSOR  INT  NOT NULL,

   VALOR         REAL DEFAULT 10.0,

   FOREIGN KEY (CD_DISCIPLINA) REFERENCES Disciplina(CD_DISCIPLINA),

   FOREIGN KEY (ID_RELATORIO)  REFERENCES RelatorioIA(ID_RELATORIO),

   FOREIGN KEY (ID_PROFESSOR)  REFERENCES Professor(ID_PROFESSOR)

);
 
CREATE TABLE Sala (

   ID_SALA       INTEGER PRIMARY KEY AUTOINCREMENT,

   CD_DISCIPLINA INT,

   ID_PROFESSOR  INT  NOT NULL,

   FOREIGN KEY (CD_DISCIPLINA) REFERENCES Disciplina(CD_DISCIPLINA),

   FOREIGN KEY (ID_PROFESSOR)  REFERENCES Professor(ID_PROFESSOR)

);
 
CREATE TABLE Sala_Aluno (

   ID_SALA  INT         NOT NULL,

   RA_ALUNO VARCHAR(20) NOT NULL,

   PRIMARY KEY (ID_SALA, RA_ALUNO),

   FOREIGN KEY (ID_SALA)  REFERENCES Sala(ID_SALA),

   FOREIGN KEY (RA_ALUNO) REFERENCES Aluno(RA)

);
 
CREATE TABLE Log_Auditoria (

   ID_LOG    INTEGER PRIMARY KEY AUTOINCREMENT,

   TABELA    VARCHAR(50),

   ACAO      VARCHAR(20),

   DESCRICAO VARCHAR(255),

   DATA_HORA TEXT

);
 
-- Inserção de Dados

INSERT INTO Professor (CPF, NOME, EMAIL, TELEFONE) VALUES 

('10000000001', 'Carlos Silva', 'carlos@escola.com', '11911111111'),

('10000000002', 'Maria Oliveira', 'maria.oliveira@escola.com', '11922222222'),

('10000000003', 'Fernando Souza', 'fernando@escola.com', '11933333333'),

('10000000004', 'Ana Costa', 'ana@escola.com', '11944444444'),

('10000000005', 'Roberto Alves', 'roberto@escola.com', '11955555555'),

('10000000006', 'Juliana Lima', 'juliana@escola.com', '11966666666'),

('10000000007', 'Ricardo Mendes', 'ricardo@escola.com', '11977777777'),

('10000000008', 'Beatriz Rocha', 'beatriz@escola.com', '11988888888'),

('10000000009', 'Marcos Dias', 'marcos@escola.com', '11999999999'),

('10000000010', 'Sandra Ramos', 'sandra@escola.com', '11900000000');
 
INSERT INTO Aluno (RA, CPF, NOME, EMAIL, TELEFONE) VALUES 

('RA001', '20000000001', 'João Souza', 'joao@estudante.com', '11970000001'),

('RA002', '20000000002', 'Ana Clara', 'anac@estudante.com', '11970000002'),

('RA003', '20000000003', 'Bruno Melo', 'bruno@estudante.com', '11970000003'),

('RA004', '20000000004', 'Carla Vaz', 'carla@estudante.com', '11970000004'),

('RA005', '20000000005', 'Diego Luz', 'diego@estudante.com', '11970000005'),

('RA006', '20000000006', 'Eduarda Gil', 'eduarda@estudante.com', '11970000006'),

('RA007', '20000000007', 'Fabio Zen', 'fabio@estudante.com', '11970000007'),

('RA008', '20000000008', 'Gisele B.', 'gisele@estudante.com', '11970000008'),

('RA009', '20000000009', 'Hugo Silva', 'hugo@estudante.com', '11970000009'),

('RA010', '20000000010', 'Igor Guia', 'igor@estudante.com', '11970000010');
 
INSERT INTO Instituicao (CNPJ, NOME, LOCALIZACAO, EMAIL, TELEFONE) VALUES

('11111111000101', 'Unidade Central', 'Predio A', 'central@inst.com', '1133330001'),

('11111111000102', 'Unidade Norte', 'Predio B', 'norte@inst.com', '1133330002'),

('11111111000103', 'Unidade Sul', 'Predio C', 'sul@inst.com', '1133330003'),

('11111111000104', 'Unidade Leste', 'Predio D', 'leste@inst.com', '1133330004'),

('11111111000105', 'Unidade Oeste', 'Predio E', 'oeste@inst.com', '1133330005'),

('11111111000106', 'Polo Digital', 'Online', 'digital@inst.com', '1133330006'),

('11111111000107', 'Centro Tecnologico', 'Predio F', 'ct@inst.com', '1133330007'),

('11111111000108', 'Polo Extensão', 'Predio G', 'extensao@inst.com', '1133330008'),

('11111111000109', 'Biblioteca Central', 'Predio H', 'bib@inst.com', '1133330009'),

('11111111000110', 'Reitoria', 'Predio Administrativo', 'reitoria@inst.com', '1133330010');
 
INSERT INTO Disciplina (NOME, ID_PROFESSOR) VALUES 

('Banco de Dados', 1), ('Lógica', 2), ('Matemática', 3), ('Redes', 4), ('SO', 5),

('Segurança', 6), ('Web', 7), ('Mobile', 8), ('IA', 9), ('Gestão', 10);
 
INSERT INTO Sala (CD_DISCIPLINA, ID_PROFESSOR) VALUES 

(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10);
 
INSERT INTO Sala_Aluno (ID_SALA, RA_ALUNO) VALUES 

(1, 'RA001'), (1, 'RA002'), (2, 'RA003'), (3, 'RA004'), (4, 'RA005'),

(5, 'RA006'), (6, 'RA007'), (7, 'RA008'), (8, 'RA009'), (9, 'RA010');
 
INSERT INTO RelatorioIA (RA_ALUNO, DATA, CD_DISCIPLINA, PONTUACAO) VALUES 

('RA001', '2026-04-10', 1, 85.5), ('RA002', '2026-04-10', 1, 90.0), ('RA003', '2026-04-11', 2, 72.3),

('RA004', '2026-04-12', 3, 60.0), ('RA005', '2026-04-13', 4, 95.0), ('RA006', '2026-04-14', 5, 88.0),

('RA007', '2026-04-15', 6, 54.5), ('RA008', '2026-04-16', 7, 79.0), ('RA009', '2026-04-17', 8, 91.5),

('RA010', '2026-04-18', 9, 100.0);
 
INSERT INTO Atividade (CD_DISCIPLINA, ID_RELATORIO, ID_PROFESSOR, VALOR) VALUES 

(1, 1, 1, 10.0), (2, 3, 2, 8.5), (3, 4, 3, 7.0), (4, 5, 4, 9.5), (5, 6, 5, 10.0),

(6, 7, 6, 6.0), (7, 8, 7, 8.0), (8, 9, 8, 9.0), (9, 10, 9, 10.0), (1, 2, 1, 9.5);
 
INSERT INTO Log_Auditoria (TABELA, ACAO, DESCRICAO, DATA_HORA) VALUES

('Sistema', 'START', 'Carga inicial efetuada', '2026-06-12 10:00:00'),

('Sistema', 'INIT', 'Registro 2', '2026-06-12 10:01:00'),

('Sistema', 'INIT', 'Registro 3', '2026-06-12 10:02:00'),

('Sistema', 'INIT', 'Registro 4', '2026-06-12 10:03:00'),

('Sistema', 'INIT', 'Registro 5', '2026-06-12 10:04:00'),

('Sistema', 'INIT', 'Registro 6', '2026-06-12 10:05:00'),

('Sistema', 'INIT', 'Registro 7', '2026-06-12 10:06:00'),

('Sistema', 'INIT', 'Registro 8', '2026-06-12 10:07:00'),

('Sistema', 'INIT', 'Registro 9', '2026-06-12 10:08:00'),

('Sistema', 'INIT', 'Registro 10', '2026-06-12 10:09:00');
 
-- Insert com Subselect

INSERT INTO Sala (CD_DISCIPLINA, ID_PROFESSOR) 

SELECT 1, ID_PROFESSOR FROM Professor WHERE NOME = 'Sandra Ramos';
 
INSERT INTO RelatorioIA (RA_ALUNO, DATA, CD_DISCIPLINA, PONTUACAO)

SELECT RA, DATE('now'), 1, 75.0 FROM Aluno WHERE NOME = 'Igor Guia';
 
INSERT INTO Atividade (CD_DISCIPLINA, ID_RELATORIO, ID_PROFESSOR, VALOR)

SELECT CD_DISCIPLINA, NULL, ID_PROFESSOR, 10.0 FROM Disciplina WHERE NOME = 'Web';
 
INSERT INTO Sala_Aluno (ID_SALA, RA_ALUNO)

SELECT (SELECT ID_SALA FROM Sala WHERE ID_PROFESSOR = 1 LIMIT 1), RA 

FROM Aluno WHERE NOME = 'João Souza';
 
INSERT INTO RelatorioIA (RA_ALUNO, DATA, CD_DISCIPLINA, PONTUACAO)

SELECT 'RA002', '2026-04-20', CD_DISCIPLINA, 82.0 FROM Disciplina WHERE ID_PROFESSOR = 2;
 
-- Update

UPDATE Professor SET EMAIL = 'carlos.novo@escola.com' WHERE CPF = '10000000001';
 
UPDATE Aluno SET TELEFONE = '11999998888' WHERE RA = 'RA001';
 
UPDATE Sala SET CD_DISCIPLINA = 5 WHERE ID_SALA = 2;
 
UPDATE Disciplina SET NOME = 'BANCO DE DADOS I' WHERE NOME = 'Banco de Dados';
 
UPDATE Atividade SET ID_PROFESSOR = 3 WHERE CD_DISCIPLINA = 1;
 
-- Remoção

DELETE FROM Sala_Aluno WHERE RA_ALUNO = 'RA010' AND ID_SALA = 9;
 
DELETE FROM Atividade WHERE ID_RELATORIO IS NULL;
 
DELETE FROM RelatorioIA WHERE DATA < '2026-01-01';
 
DELETE FROM Sala_Aluno WHERE RA_ALUNO = 'RA003';
 
DELETE FROM Sala WHERE ID_SALA = 10;
 
-- Consulta com Inner Join

SELECT A.NOME, S.ID_SALA, P.NOME AS PROFESSOR

FROM Aluno A

INNER JOIN Sala_Aluno SA ON A.RA = SA.RA_ALUNO

INNER JOIN Sala S ON SA.ID_SALA = S.ID_SALA

INNER JOIN Professor P ON S.ID_PROFESSOR = P.ID_PROFESSOR;
 
SELECT D.NOME, P.NOME

FROM Disciplina D

INNER JOIN Professor P ON D.ID_PROFESSOR = P.ID_PROFESSOR;
 
SELECT R.ID_RELATORIO, A.NOME, D.NOME

FROM RelatorioIA R

INNER JOIN Aluno A ON R.RA_ALUNO = A.RA

INNER JOIN Disciplina D ON R.CD_DISCIPLINA = D.CD_DISCIPLINA;
 
SELECT AT.ID_ATVD, P.NOME, D.NOME

FROM Atividade AT

INNER JOIN Professor P ON AT.ID_PROFESSOR = P.ID_PROFESSOR

INNER JOIN Disciplina D ON AT.CD_DISCIPLINA = D.CD_DISCIPLINA;
 
SELECT A.NOME

FROM Aluno A

INNER JOIN Sala_Aluno SA ON A.RA = SA.RA_ALUNO

INNER JOIN Sala S ON SA.ID_SALA = S.ID_SALA

INNER JOIN Disciplina D ON S.CD_DISCIPLINA = D.CD_DISCIPLINA

WHERE D.NOME = 'BANCO DE DADOS I';
 
-- Consulta com Subquery

SELECT NOME 

FROM Aluno 

WHERE RA IN (SELECT RA_ALUNO FROM Sala_Aluno WHERE ID_SALA = 1);
 
SELECT NOME 

FROM Disciplina 

WHERE ID_PROFESSOR = (SELECT ID_PROFESSOR FROM Professor WHERE NOME = 'Carlos Silva');
 
SELECT NOME, 

       (SELECT COUNT(*) FROM RelatorioIA WHERE RA_ALUNO = Aluno.RA) AS Total_Relatorios

FROM Aluno;
 
SELECT NOME 

FROM Professor 

WHERE ID_PROFESSOR NOT IN (SELECT DISTINCT ID_PROFESSOR FROM Sala);
 
SELECT ID_SALA 

FROM Sala 

WHERE CD_DISCIPLINA IN (SELECT CD_DISCIPLINA FROM Disciplina WHERE NOME LIKE '%I%');
 
-- Criação de Views

CREATE VIEW vw_Ocupacao_Salas AS

SELECT S.ID_SALA, COUNT(SA.RA_ALUNO) AS Total_Alunos

FROM Sala S

LEFT JOIN Sala_Aluno SA ON S.ID_SALA = SA.ID_SALA

GROUP BY S.ID_SALA;
 
CREATE VIEW vw_Grade_Professores AS

SELECT P.NOME AS Professor, D.NOME AS Disciplina

FROM Professor P

INNER JOIN Disciplina D ON P.ID_PROFESSOR = D.ID_PROFESSOR;
 
CREATE VIEW vw_Atividades_Alunos AS

SELECT A.NOME AS Aluno, AT.ID_ATVD, D.NOME AS Disciplina

FROM Aluno A

INNER JOIN RelatorioIA R ON A.RA = R.RA_ALUNO

INNER JOIN Atividade AT ON R.ID_RELATORIO = AT.ID_RELATORIO

INNER JOIN Disciplina D ON AT.CD_DISCIPLINA = D.CD_DISCIPLINA;
 
CREATE VIEW vw_Relatorios_Pontuacao AS

SELECT R.ID_RELATORIO, R.PONTUACAO, R.DATA, A.NOME AS Aluno

FROM RelatorioIA R

INNER JOIN Aluno A ON R.RA_ALUNO = A.RA;
 
CREATE VIEW vw_Valores_Atividades AS

SELECT AT.ID_ATVD, AT.VALOR, D.NOME AS Disciplina

FROM Atividade AT

INNER JOIN Disciplina D ON AT.CD_DISCIPLINA = D.CD_DISCIPLINA;
 
-- Consultas a partir das Views

SELECT COUNT(ID_SALA) AS Salas_Com_Mais_De_Um_Aluno FROM vw_Ocupacao_Salas WHERE Total_Alunos > 1;
 
SELECT SUM(VALOR) AS Carga_Total_Atividades FROM vw_Valores_Atividades;
 
SELECT AVG(PONTUACAO) AS Media_Geral_Pontuacao FROM vw_Relatorios_Pontuacao;
 
SELECT MIN(PONTUACAO) AS Pior_Nota, MAX(PONTUACAO) AS Melhor_Nota FROM vw_Relatorios_Pontuacao;
 
SELECT Aluno, Disciplina FROM vw_Atividades_Alunos WHERE Disciplina IN ('BANCO DE DADOS I', 'Lógica') AND ID_ATVD BETWEEN 1 AND 50;
 
-- Criação de Índices (INDEX)

CREATE INDEX idx_aluno_nome ON Aluno(NOME);

CREATE INDEX idx_professor_cpf ON Professor(CPF);

CREATE INDEX idx_relatorio_data ON RelatorioIA(DATA);

CREATE INDEX idx_sala_busca ON Sala(CD_DISCIPLINA, ID_PROFESSOR);

CREATE INDEX idx_sala_aluno_ra ON Sala_Aluno(RA_ALUNO);
 
-- Criação de Triggers

CREATE TRIGGER tg_Garante_Data_Relatorio

AFTER INSERT ON RelatorioIA

FOR EACH ROW

WHEN NEW.DATA IS NULL

BEGIN

    UPDATE RelatorioIA SET DATA = DATE('now') WHERE ID_RELATORIO = NEW.ID_RELATORIO;

END;
 
CREATE TRIGGER tg_Limpa_Vias_Aluno_SALA

BEFORE DELETE ON Aluno

FOR EACH ROW

BEGIN

    DELETE FROM Sala_Aluno WHERE RA_ALUNO = OLD.RA;

END;
 
CREATE TRIGGER tg_Previne_Professor_Sem_CPF

BEFORE INSERT ON Professor

FOR EACH ROW

WHEN LENGTH(NEW.CPF) != 11

BEGIN

    SELECT RAISE(ABORT, 'O CPF deve possuir exatamente 11 caracteres.');

END;
 
CREATE TRIGGER tg_Auto_Vincula_Atividade_Professor

AFTER INSERT ON Atividade

FOR EACH ROW

WHEN NEW.ID_PROFESSOR IS NULL

BEGIN

    UPDATE Atividade 

    SET ID_PROFESSOR = (SELECT ID_PROFESSOR FROM Disciplina WHERE CD_DISCIPLINA = NEW.CD_DISCIPLINA)

    WHERE ID_ATVD = NEW.ID_ATVD;

END;
 
CREATE TRIGGER tg_Log_Mudanca_Email_Aluno

AFTER UPDATE OF EMAIL ON Aluno

FOR EACH ROW

BEGIN

    INSERT INTO Log_Auditoria(TABELA, ACAO, DESCRICAO, DATA_HORA)

    VALUES ('Aluno', 'UPDATE_EMAIL', 'E-mail alterado de ' || OLD.EMAIL || ' para ' || NEW.EMAIL, DATETIME('now'));

END;
 
-- Triggers que chamam Funções ou Procedures

CREATE TRIGGER tg_Validacao_E_Log_Insert_Professor

AFTER INSERT ON Professor

FOR EACH ROW

BEGIN

    INSERT INTO Log_Auditoria (TABELA, ACAO, DESCRICAO, DATA_HORA)

    VALUES ('Professor', 'INSERT', 'Professor ID ' || NEW.ID_PROFESSOR || ' inserido com sucesso.', DATETIME('now'));

END;
 
CREATE TRIGGER tg_Auditoria_Exclusao_Professor

AFTER DELETE ON Professor

FOR EACH ROW

BEGIN

    INSERT INTO Log_Auditoria (TABELA, ACAO, DESCRICAO, DATA_HORA)

    VALUES ('Professor', 'DELETE', 'Professor ' || OLD.NOME || ' foi removido do sistema.', DATETIME('now'));

END;
 
CREATE TRIGGER tg_Ajusta_Pontuacao_Relatorio_Insert

AFTER INSERT ON RelatorioIA

FOR EACH ROW

BEGIN

    UPDATE RelatorioIA

    SET PONTUACAO = ROUND(NEW.PONTUACAO, 2)

    WHERE ID_RELATORIO = NEW.ID_RELATORIO;

END;
 
CREATE TRIGGER tg_Auditoria_Update_Atividade

AFTER UPDATE OF VALOR ON Atividade

FOR EACH ROW

BEGIN

    INSERT INTO Log_Auditoria (TABELA, ACAO, DESCRICAO, DATA_HORA)

    VALUES ('Atividade', 'UPDATE_VALOR', 'ID ' || NEW.ID_ATVD || ' valor mudou de ' || OLD.VALOR || ' para ' || NEW.VALOR, DATETIME('now'));

END;
 
CREATE TRIGGER tg_Protecao_Exclusao_Instituicao

BEFORE DELETE ON Instituicao

FOR EACH ROW

BEGIN

    SELECT RAISE(ABORT, 'Exclusões na tabela Instituição não são permitidas por diretrizes de auditoria.');

END;
 
-- Transações

BEGIN TRANSACTION;

INSERT INTO Professor (CPF, NOME, EMAIL, TELEFONE) VALUES ('99999999999', 'Transação 1', 't1@escola.com', '110000000');

INSERT INTO Disciplina (NOME, ID_PROFESSOR) VALUES ('Materia Transacional 1', (SELECT last_insert_rowid()));

COMMIT;
 
BEGIN TRANSACTION;

UPDATE Aluno SET TELEFONE = '11999999999' WHERE RA = 'RA001';

UPDATE Aluno SET TELEFONE = '11888888888' WHERE RA = 'RA002';

COMMIT;
 
BEGIN TRANSACTION;

DELETE FROM Sala_Aluno WHERE ID_SALA = 2;

DELETE FROM Sala WHERE ID_SALA = 2;

COMMIT;
 
BEGIN TRANSACTION;

INSERT INTO RelatorioIA (RA_ALUNO, DATA, CD_DISCIPLINA, PONTUACAO) VALUES ('RA001', DATE('now'), 1, 88.0);

UPDATE Aluno SET EMAIL = 'joao.novo@email.com' WHERE RA = 'RA001';

COMMIT;
 
BEGIN TRANSACTION;

INSERT INTO Instituicao (CNPJ, NOME, LOCALIZACAO, EMAIL, TELEFONE) VALUES ('22222222000102', 'Polo Temporario', 'Erro', 'erro@inst.com', '110');

ROLLBACK;
 
