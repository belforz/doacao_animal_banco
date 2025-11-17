-- Script SQL para o banco de dados doacao_animal
-- Considerando strings como VARCHAR(255), datas como DATETIME, ids como INT AUTO_INCREMENT

CREATE DATABASE IF NOT EXISTS doacao_animal;
USE doacao_animal;
-- drop database doacao_animal;

-- Tabela Protetor (herda de Pessoa)
CREATE TABLE Protetor (
    idProtetor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255),
    email VARCHAR(255),
    documento VARCHAR(255) UNIQUE,
    telefone VARCHAR(255),
    senha VARCHAR(255),
    endereco VARCHAR(255),
    tipo VARCHAR(255)
);

-- Tabela Adotante (herda de Pessoa)
CREATE TABLE Adotante (
    idAdotante INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255),
    email VARCHAR(255),
    documento VARCHAR(255) UNIQUE,
    telefone VARCHAR(255),
    senha VARCHAR(255),
    endereco VARCHAR(255),
    preferenciaAdocao VARCHAR(255)
);

-- Tabela Animal
CREATE TABLE Animal (
    idAnimal INT PRIMARY KEY AUTO_INCREMENT,
    especie VARCHAR(255),
    raca VARCHAR(255),
    temperamento VARCHAR(255),
    historicoSaude VARCHAR(255),
    nome VARCHAR(255),
    descricao VARCHAR(255),
    esEspecial TINYINT(1),
    idade INT,
    sexo CHAR(1),
    status VARCHAR(255),
    id_protetor INT NOT NULL,
    FOREIGN KEY (id_protetor) REFERENCES Protetor(idProtetor) ON DELETE CASCADE
);

-- Tabela FotoAnimal
CREATE TABLE FotoAnimal (
    idFotoAnimal INT PRIMARY KEY AUTO_INCREMENT,
    urlAnimal VARCHAR(255),
    descricaoFoto VARCHAR(255),
    idAnimal INT NOT NULL,
    FOREIGN KEY (idAnimal) REFERENCES Animal(idAnimal) ON DELETE CASCADE
);

-- Tabela ProcessoAdocao
CREATE TABLE ProcessoAdocao (
    idPAdocao INT PRIMARY KEY AUTO_INCREMENT,
    id_animal INT NOT NULL,
    id_adotante INT NOT NULL,
    status VARCHAR(255),
    dataInicio DATETIME,
    FOREIGN KEY (id_animal) REFERENCES Animal(idAnimal) ON DELETE CASCADE,
    FOREIGN KEY (id_adotante) REFERENCES Adotante(idAdotante) ON DELETE CASCADE
);

-- Tabela EtapaProcesso (adicionado id para chave primária)
CREATE TABLE EtapaProcesso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    data DATETIME,
    observacoes VARCHAR(255),
    id_processo INT NOT NULL,
    statusEtapa VARCHAR(255),
    tipoEtapa VARCHAR(255),
    FOREIGN KEY (id_processo) REFERENCES ProcessoAdocao(idPAdocao) ON DELETE CASCADE
);


-- Tabela Mensagem
CREATE TABLE Mensagem (
    idMensagem INT PRIMARY KEY AUTO_INCREMENT,
    dataMensagem DATETIME,
    conteudo VARCHAR(255),
    idRemetente INT,
    tipoRemetente VARCHAR(10),
    idDestinatario INT,
    tipoDestinatario VARCHAR(10),
    id_processo int,
    FOREIGN KEY (id_processo) REFERENCES ProcessoAdocao(idPAdocao) ON DELETE CASCADE

);

---- Tabela de junção para ProcessoAdocao e Mensagem
--CREATE TABLE Processo_Mensagem (
--    idPMensagem INT PRIMARY KEY AUTO_INCREMENT,
--    id_processo INT,
--    id_mensagem INT,
--    PRIMARY KEY (id_processo, id_mensagem),
--    FOREIGN KEY (id_processo) REFERENCES ProcessoAdocao(idPAdocao) ON DELETE CASCADE,
--    FOREIGN KEY (id_mensagem) REFERENCES Mensagem(idMensagem) ON DELETE CASCADE
--);

-- Tabela Adocao
CREATE TABLE Adocao (
    idAdocao INT PRIMARY KEY AUTO_INCREMENT,
    dataAdocao DATETIME,
    descricao VARCHAR(255),
    termos VARCHAR(255),
    id_processo INT NOT NULL UNIQUE,
    FOREIGN KEY (id_processo) REFERENCES ProcessoAdocao(idPAdocao) ON DELETE CASCADE
);

-- Tabela SuportePosAdocao
CREATE TABLE SuportePosAdocao (
    idSuporte INT PRIMARY KEY AUTO_INCREMENT,
    dataRegistro DATETIME,
    tipoSolicitacao VARCHAR(255),
    descricao VARCHAR(255),
    idAdocao INT,
    FOREIGN KEY (idAdocao) REFERENCES Adocao(idAdocao) ON DELETE CASCADE
);

-- Tabela LogAuditoria de um insert
CREATE TABLE LogAuditoria (
    idLog INT PRIMARY KEY AUTO_INCREMENT,
    dataRegistro timestamp not null default current_timestamp,
    tabelaModificada VARCHAR(255),
    registro JSON not null
);



-- Tabela de Log de Auditoria para Updates
CREATE TABLE LogAuditoriaUpdate (
    idLog INT PRIMARY KEY AUTO_INCREMENT,
    dataRegistro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tabelaModificada VARCHAR(255),
    registroAnterior JSON NOT NULL,
    registroNovo JSON NOT NULL
);

show tables;

CREATE TRIGGER log_auditoria_insert_adocao
AFTER INSERT ON Adocao
FOR EACH ROW
BEGIN
  INSERT INTO LogAuditoria (
    dataRegistro,
    tabelaModificada,
    registro
  ) VALUES (
    NOW(),
    'adocao',
    JSON_OBJECT(
      'idAdocao',    NEW.idAdocao,
      'dataAdocao',  NEW.dataAdocao,
      'descricao',   NEW.descricao,
      'termos',      NEW.termos,
      'id_processo', NEW.id_processo
    )
  );
END;

-- ============================================================
-- Triggers
-- ============================================================

-- UPDATE em Adotante
CREATE TRIGGER log_auditoria_update_adotante
AFTER UPDATE ON Adotante
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'id',        OLD.idAdotante,
    'nome',      OLD.nome,
    'email',     OLD.email,
    'documento', OLD.documento,
    'telefone',  OLD.telefone,
    'senha',     OLD.senha,
    'endereco',  OLD.endereco,
    'preferenciaAdocao',      OLD.preferenciaAdocao
  );

  SET newData = JSON_OBJECT(
    'id',        NEW.idAdotante,
    'nome',      NEW.nome,
    'email',     NEW.email,
    'documento', NEW.documento,
    'telefone',  NEW.telefone,
    'senha',     NEW.senha,
    'endereco',  NEW.endereco,
    'preferenciaAdocao',      NEW.preferenciaAdocao
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'adotante', oldData, newData);
end;

-- UPDATE em Protetor
CREATE TRIGGER log_auditoria_update_protetor
AFTER UPDATE ON Protetor
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'id',                OLD.idProtetor,
    'nome',              OLD.nome,
    'email',             OLD.email,
    'documento',         OLD.documento,
    'telefone',          OLD.telefone,
    'senha',             OLD.senha,
    'endereco',          OLD.endereco,
    'tipo', OLD.tipo
  );

  SET newData = JSON_OBJECT(
    'id',                NEW.idProtetor,
    'nome',              NEW.nome,
    'email',             NEW.email,
    'documento',         NEW.documento,
    'telefone',          NEW.telefone,
    'senha',             NEW.senha,
    'endereco',          NEW.endereco,
    'tipo', NEW.tipo
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'protetor', oldData, newData);
end;

-- UPDATE em Animal
CREATE TRIGGER log_auditoria_update_animal
AFTER UPDATE ON Animal
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'id',             OLD.idAnimal,
    'especie',        OLD.especie,
    'raca',           OLD.raca,
    'temperamento',   OLD.temperamento,
    'historicoSaude', OLD.historicoSaude,
    'nome',           OLD.nome,
    'descricao',      OLD.descricao,
    'esEspecial',     OLD.especial,
    'idade',          OLD.idade,
    'sexo',           OLD.sexo,
    'status',         OLD.status,
    'id_protetor',        OLD.id_protetor
  );

  SET newData = JSON_OBJECT(
    'id',             NEW.idAnimal,
    'especie',        NEW.especie,
    'raca',           NEW.raca,
    'temperamento',   NEW.temperamento,
    'historicoSaude', NEW.historicoSaude,
    'nome',           NEW.nome,
    'descricao',      NEW.descricao,
    'esEspecial',     NEW.especial,
    'idade',          NEW.idade,
    'sexo',           NEW.sexo,
    'status',         NEW.status,
    'id_protetor',        NEW.id_protetor
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'animal', oldData, newData);
end;

-- UPDATE em FotoAnimal
CREATE TRIGGER log_auditoria_update_fotoanimal
AFTER UPDATE ON FotoAnimal
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'idFotoAnimal',  OLD.idFotoAnimal,
    'urlAnimal',     OLD.urlAnimal,
    'descricaoFoto', OLD.descricaoFoto,
    'idAnimal',      OLD.idAnimal
  );

  SET newData = JSON_OBJECT(
    'idFotoAnimal',  NEW.idFotoAnimal,
    'urlAnimal',     NEW.urlAnimal,
    'descricaoFoto', NEW.descricaoFoto,
    'idAnimal',      NEW.idAnimal
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'fotoanimal', oldData, newData);
end;

-- UPDATE em ProcessoAdocao
CREATE TRIGGER log_auditoria_update_processoadocao
AFTER UPDATE ON ProcessoAdocao
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'idPAdocao',  OLD.idPAdocao,
    'id_animal',  OLD.id_animal,
    'id_adotante',OLD.id_adotante,
    'status',     OLD.status,
    'dataInicio',  OLD.dataInicio
  );

  SET newData = JSON_OBJECT(
    'idPAdocao',  NEW.idPAdocao,
    'id_animal',  NEW.id_animal,
    'id_adotante',NEW.id_adotante,
    'status',     NEW.status,
    'dataInicio',  NEW.dataInicio
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'processoadocao', oldData, newData);
end;

-- UPDATE em EtapaProcesso
CREATE TRIGGER log_auditoria_update_etapaprocesso
AFTER UPDATE ON EtapaProcesso
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'id',           OLD.id,
    'data',         OLD.data,
    'observacoes',  OLD.observacoes,
    'id_processo' , OLD.id_processo,
    'statusEtapa',  OLD.statusEtapa,
    'tipoEtapa',    OLD.tipoEtapa
  );

  SET newData = JSON_OBJECT(
    'id',           NEW.id,
    'data',         NEW.data,
    'observacoes',  NEW.observacoes,
    'id_processo' , NEW.id_processo,
    'statusEtapa',  NEW.statusEtapa,
    'tipoEtapa',    NEW.tipoEtapa
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'etapaprocesso', oldData, newData);
end;

-- UPDATE em Mensagem
CREATE TRIGGER log_auditoria_update_mensagem
AFTER UPDATE ON Mensagem
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'idMensagem',     OLD.idMensagem,
    'dataMensagem',   OLD.dataMensagem,
    'conteudo',       OLD.conteudo,
    'idRemetente',    OLD.idRemetente,
    'tipoRemetente',  OLD.tipoRemetente,
    'idDestinatario', OLD.idDestinatario,
    'tipoDestinatario', OLD.tipoDestinatario,
    'id_processo',    OLD.id_processo
  );

  SET newData = JSON_OBJECT(
    'idMensagem',     NEW.idMensagem,
    'dataMensagem',   NEW.dataMensagem,
    'conteudo',       NEW.conteudo,
    'idRemetente',    NEW.idRemetente,
    'tipoRemetente',  NEW.tipoRemetente,
    'idDestinatario', NEW.idDestinatario,
    'tipoDestinatario', NEW.tipoDestinatario,
    'id_processo',    NEW.id_processo
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'mensagem', oldData, newData);
end;

-- UPDATE em Adocao
CREATE TRIGGER log_auditoria_update_adocao
AFTER UPDATE ON Adocao
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'idAdocao',    OLD.idAdocao,
    'dataAdocao',  OLD.dataAdocao,
    'descricao',   OLD.descricao,
    'termos',      OLD.termos,
    'id_processo', OLD.id_processo
  );

  SET newData = JSON_OBJECT(
    'idAdocao',    NEW.idAdocao,
    'dataAdocao',  NEW.dataAdocao,
    'descricao',   NEW.descricao,
    'termos',      NEW.termos,
    'id_processo', NEW.id_processo
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'adocao', oldData, newData);
end;

-- UPDATE em SuportePosAdocao
CREATE TRIGGER log_auditoria_update_suporteposadocao
AFTER UPDATE ON SuportePosAdocao
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'idSuporte',     OLD.idSuporte,
    'dataRegistro',  OLD.dataRegistro,
    'tipoSolicitacao', OLD.tipoSolicitacao,
    'descricao',     OLD.descricao,
    'idAdocao',      OLD.idAdocao
  );

  SET newData = JSON_OBJECT(
    'idSuporte',     NEW.idSuporte,
    'dataRegistro',  NEW.dataRegistro,
    'tipoSolicitacao', NEW.tipoSolicitacao,
    'descricao',     NEW.descricao,
    'idAdocao',      NEW.idAdocao
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'suporteposadocao', oldData, newData);
end;

-- UPDATE em Processo_Mensagem

CREATE TRIGGER log_auditoria_update_processo_mensagem
AFTER UPDATE ON Processo_Mensagem
FOR EACH ROW
BEGIN
  DECLARE oldData JSON;
  DECLARE newData JSON;

  SET oldData = JSON_OBJECT(
    'id_processo', OLD.id_processo,
    'id_mensagem', OLD.id_mensagem
  );

  SET newData = JSON_OBJECT(
    'id_processo', NEW.id_processo,
    'id_mensagem', NEW.id_mensagem
  );

  INSERT INTO LogAuditoriaUpdate (dataRegistro, tabelaModificada, registroAnterior, registroNovo)
  VALUES (NOW(), 'processo_mensagem', oldData, newData);
end;

-- Inserções

-- Protetores
INSERT INTO Protetor (nome, email, documento, telefone, senha, endereco, tipo) VALUES
('João Silva', 'joao@email.com', '123456789', '11987654321', 'senha123', 'Rua A, 123', 'Individual'),
('Maria Oliveira', 'maria@email.com', '987654321', '11876543210', 'senha456', 'Rua B, 456', 'Família'),
('Carlos Santos', 'carlos@email.com', '456789123', '11765432109', 'senha789', 'Rua C, 789', 'Individual'),
('Ana Costa', 'ana@email.com', '321654987', '11654321098', 'senha101', 'Rua D, 101', 'Família'),
('Pedro Lima', 'pedro@email.com', '654987321', '11543210987', 'senha202', 'Rua E, 102', 'Individual'),
('Laura Martins', 'laura@email.com', '11122233344', '11999999991', 'senha111', 'Rua K, 111', 'Família'),
('Bruno Souza', 'bruno@email.com', '22233344455', '11999999992', 'senha222', 'Rua L, 112', 'Individual'),
('Patrícia Lima', 'patricia@email.com', '33344455566', '11999999993', 'senha333', 'Rua M, 113', 'Família'),
('Eduardo Alves', 'eduardo@email.com', '44455566677', '11999999994', 'senha444', 'Rua N, 114', 'Individual'),
('Renata Costa', 'renata@email.com', '55566677788', '11999999995', 'senha555', 'Rua O, 115', 'Família'),
('Felipe Rocha', 'felipe@email.com', '66677788899', '11999999996', 'senha666', 'Rua P, 116', 'Individual'),
('Camila Ribeiro', 'camila@email.com', '77788899900', '11999999997', 'senha777', 'Rua Q, 117', 'Família'),
('Daniel Fernandes', 'daniel@email.com', '88899900011', '11999999998', 'senha888', 'Rua R, 118', 'Individual'),
('Aline Barros', 'aline@email.com', '99900011122', '11999999999', 'senha999', 'Rua S, 119', 'Família'),
('Gustavo Teixeira', 'gustavo@email.com', '00011122233', '11988888888', 'senha000', 'Rua T, 120', 'Individual'),
('Isabela Cunha', 'isabela@email.com', '11122233345', '11977777777', 'senhaabc', 'Rua U, 121', 'Família'),
('Rafael Mendes', 'rafael@email.com', '22233344456', '11966666666', 'senhaxyz', 'Rua V, 122', 'Individual'),
('Vanessa Lopes', 'vanessa@email.com', '33344455567', '11955555555', 'senhaqwe', 'Rua W, 123', 'Família'),
('Rodrigo Neves', 'rodrigo@email.com', '44455566678', '11944444444', 'senhazxc', 'Rua X, 124', 'Individual'),
('Beatriz Silva', 'beatriz@email.com', '55566677789', '11933333333', 'senhasdf', 'Rua Y, 125', 'Família');


-- Adotantes
INSERT INTO Adotante (nome, email, documento, telefone, senha, endereco, preferenciaAdocao) VALUES
('Lucas Pereira', 'lucas@email.com', '111222333', '11432109876', 'senha303', 'Rua F, 303', 'Cachorros'),
('Fernanda Rocha', 'fernanda@email.com', '444555666', '11321098765', 'senha404', 'Rua G, 404', 'Gatos'),
('Roberto Alves', 'roberto@email.com', '777888999', '11210987654', 'senha505', 'Rua H, 505', 'Pássaros'),
('Juliana Mendes', 'juliana@email.com', '000111222', '11109876543', 'senha606', 'Rua I, 606', 'Cachorros'),
('Thiago Nunes', 'thiago@email.com', '333444555', '11098765432', 'senha707', 'Rua J, 707', 'Gatos'),
('André Gomes', 'andre@email.com', '12312312312', '11911111111', 'senha808', 'Rua Z, 126', 'Cachorros'),
('Tatiane Freitas', 'tatiane@email.com', '23423423423', '11922222222', 'senha909', 'Rua AA, 127', 'Gatos'),
('Marcelo Dias', 'marcelo@email.com', '34534534534', '11933333333', 'senha010', 'Rua AB, 128', 'Pássaros'),
('Carolina Pinto', 'carolina@email.com', '45645645645', '11944444444', 'senha111', 'Rua AC, 129', 'Cachorros'),
('Diego Moreira', 'diego@email.com', '56756756756', '11955555555', 'senha212', 'Rua AD, 130', 'Gatos'),
('Simone Tavares', 'simone@email.com', '67867867867', '11966666666', 'senha313', 'Rua AE, 131', 'Pássaros'),
('Henrique Castro', 'henrique@email.com', '78978978978', '11977777777', 'senha414', 'Rua AF, 132', 'Cachorros'),
('Elaine Duarte', 'elaine@email.com', '89089089089', '11988888888', 'senha515', 'Rua AG, 133', 'Gatos'),
('Fábio Cardoso', 'fabio@email.com', '90190190190', '11999999999', 'senha616', 'Rua AH, 134', 'Pássaros'),
('Natalia Reis', 'natalia@email.com', '01201201201', '11888888888', 'senha717', 'Rua AI, 135', 'Cachorros'),
('Jorge Santana', 'jorge@email.com', '12312312345', '11777777777', 'senha818', 'Rua AJ, 136', 'Gatos'),
('Luciana Prado', 'luciana@email.com', '23423423456', '11666666666', 'senha919', 'Rua AK, 137', 'Pássaros'),
('Paulo Henrique', 'paulo@email.com', '34534534567', '11555555555', 'senha020', 'Rua AL, 138', 'Cachorros'),
('Sabrina Moraes', 'sabrina@email.com', '45645645678', '11444444444', 'senha121', 'Rua AM, 139', 'Gatos'),
('Renan Farias', 'renan@email.com', '56756756789', '11333333333', 'senha222', 'Rua AN, 140', 'Pássaros');


-- Animais
INSERT INTO Animal (especie, raca, temperamento, historicoSaude, nome, descricao, esEspecial, idade, sexo, status, id_protetor) VALUES
('Cachorro', 'Labrador', 'Amigável', 'Vacinado', 'Rex', 'Cachorro brincalhão', 0, 2, 'M', 'Disponível', 1),
('Gato', 'Siamês', 'Calmo', 'Castrado', 'Mia', 'Gata carinhosa', 0, 1, 'F', 'Disponível', 2),
('Cachorro', 'Poodle', 'Energético', 'Vacinado', 'Bella', 'Cachorra pequena', 0, 3, 'F', 'Disponível', 3),
('Gato', 'Persa', 'Preguiçoso', 'Castrado', 'Tom', 'Gato dorminhoco', 0, 4, 'M', 'Disponível', 4),
('Pássaro', 'Canário', 'Canto', 'Saudável', 'Piu', 'Pássaro cantor', 0, 1, 'M', 'Disponível', 5),
('Cachorro', 'Beagle', 'Curioso', 'Vacinado', 'Toby', 'Beagle esperto', 0, 2, 'M', 'Disponível', 6),
('Gato', 'Maine Coon', 'Sociável', 'Castrado', 'Luna', 'Gata grande e gentil', 0, 3, 'F', 'Disponível', 7),
('Pássaro', 'Papagaio', 'Falante', 'Saudável', 'Loro', 'Papagaio divertido', 1, 5, 'M', 'Disponível', 8),
('Cachorro', 'Bulldog', 'Tranquilo', 'Vacinado', 'Max', 'Bulldog preguiçoso', 0, 4, 'M', 'Disponível', 9),
('Gato', 'Bengal', 'Ativo', 'Castrado', 'Zoe', 'Gata ágil', 0, 2, 'F', 'Disponível', 10),
('Pássaro', 'Periquito', 'Brincalhão', 'Saudável', 'Bico', 'Periquito colorido', 0, 1, 'M', 'Disponível', 11),
('Cachorro', 'Golden Retriever', 'Amável', 'Vacinado', 'Duke', 'Companheiro fiel', 0, 3, 'M', 'Disponível', 12),
('Gato', 'Angorá', 'Elegante', 'Castrado', 'Nina', 'Gata peluda', 0, 2, 'F', 'Disponível', 13),
('Pássaro', 'Arara', 'Exótico', 'Saudável', 'Azul', 'Arara azul vibrante', 1, 6, 'F', 'Disponível', 14),
('Cachorro', 'Chihuahua', 'Alerta', 'Vacinado', 'Spike', 'Pequeno e valente', 0, 1, 'M', 'Disponível', 15),
('Gato', 'Ragdoll', 'Calmo', 'Castrado', 'Mel', 'Gata doce', 0, 3, 'F', 'Disponível', 16),
('Pássaro', 'Calopsita', 'Cantor', 'Saudável', 'Caco', 'Calopsita alegre', 0, 2, 'M', 'Disponível', 17),
('Cachorro', 'Husky', 'Independente', 'Vacinado', 'Thor', 'Husky aventureiro', 0, 4, 'M', 'Disponível', 18),
('Gato', 'Sphynx', 'Curioso', 'Castrado', 'Lua', 'Gato sem pelos', 0, 1, 'F', 'Disponível', 19),
('Pássaro', 'Tucano', 'Silencioso', 'Saudável', 'Bico Preto', 'Tucano tropical', 1, 5, 'M', 'Disponível', 20);


-- Fotos de Animais
INSERT INTO FotoAnimal (urlAnimal, descricaoFoto, idAnimal) VALUES
('http://example.com/rex1.jpg', 'Foto do Rex brincando', 1),
('http://example.com/mia1.jpg', 'Foto da Mia dormindo', 2),
('http://example.com/toby1.jpg', 'Toby explorando o jardim', 6),
('http://example.com/luna1.jpg', 'Luna em cima da estante', 7),
('http://example.com/loro1.jpg', 'Loro falando com visitantes', 8),
('http://example.com/max1.jpg', 'Max dormindo no sofá', 9),
('http://example.com/zoe1.jpg', 'Zoe correndo atrás de brinquedo', 10),
('http://example.com/bico1.jpg', 'Bico empoleirado', 11),
('http://example.com/duke1.jpg', 'Duke brincando com bola', 12),
('http://example.com/nina1.jpg', 'Nina se espreguiçando', 13),
('http://example.com/azul1.jpg', 'Arara Azul em voo', 14),
('http://example.com/spike1.jpg', 'Spike latindo', 15),
('http://example.com/mel1.jpg', 'Mel deitada na cama', 16),
('http://example.com/caco1.jpg', 'Caco cantando', 17),
('http://example.com/thor1.jpg', 'Thor na neve', 18),
('http://example.com/lua1.jpg', 'Lua olhando pela janela', 19),
('http://example.com/bicopreto1.jpg', 'Tucano empoleirado', 20),
('http://example.com/bella1.jpg', 'Bella com coleira', 3),
('http://example.com/tom1.jpg', 'Tom no jardim', 4),
('http://example.com/piu1.jpg', 'Piu cantando', 5);

-- Processos de Adoção
INSERT INTO ProcessoAdocao (id_animal, id_adotante, status, dataInicio) VALUES
(1, 1, 'APROVADO', '2023-01-01 10:00:00'),
(2, 2, 'ENTREVISTA', '2023-02-01 11:00:00'),
(3, 3, 'TRIAGEM', '2023-03-01 12:00:00'),
(4, 4, 'VISITA_DOMICILIAR', '2023-04-01 13:00:00'),
(5, 5, 'CONTRATO', '2023-05-01 14:00:00'),
(6, 6, 'RASCUNHO', '2023-06-01 09:00:00'),
(7, 7, 'SUBMETIDO', '2023-07-01 10:00:00'),
(8, 8, 'TRIAGEM', '2023-08-01 11:00:00'),
(9, 9, 'ENTREVISTA', '2023-09-01 12:00:00'),
(10, 10, 'VISITA_DOMICILIAR', '2023-10-01 13:00:00'),
(11, 11, 'APROVADO', '2023-11-01 14:00:00'),
(12, 12, 'CONTRATO', '2023-12-01 15:00:00'),
(13, 13, 'CONCLUIDO', '2024-01-01 16:00:00'),
(14, 14, 'POS_ADOCAO', '2024-02-01 17:00:00'),
(15, 15, 'ENCERRADO', '2024-03-01 18:00:00'),
(16, 16, 'RASCUNHO', '2024-04-01 19:00:00'),
(17, 17, 'SUBMETIDO', '2024-05-01 20:00:00'),
(18, 18, 'TRIAGEM', '2024-06-01 21:00:00'),
(19, 19, 'ENTREVISTA', '2024-07-01 22:00:00'),
(20, 20, 'VISITA_DOMICILIAR', '2024-08-01 23:00:00');

-- Etapas de Processo
INSERT INTO EtapaProcesso (data, observacoes, id_processo, statusEtapa, tipoEtapa) VALUES
('2023-01-02 12:00:00', 'Entrevista inicial', 1, 'PENDENTE', 'ENTREVISTA'),
('2023-01-03 13:00:00', 'Visita domiciliar', 1, 'CONCLUIDA', 'VISITA'),
('2023-02-02 14:00:00', 'Triagem concluída', 2, 'CONCLUIDA', 'TRIAGEM'),
('2023-03-02 15:00:00', 'Visita realizada', 3, 'CONCLUIDA', 'VISITA'),
('2023-04-02 16:00:00', 'Contrato assinado', 4, 'CONCLUIDA', 'CONTRATO'),
('2024-09-01 10:00:00', 'Nova etapa iniciada', 5, 'PENDENTE', 'ENTREVISTA'),
('2024-10-01 11:00:00', 'Revisão de documentos', 6, 'PENDENTE', 'TRIAGEM'),
('2024-11-01 12:00:00', 'Aprovação pendente', 7, 'PENDENTE', 'APROVACAO'),
('2024-12-01 13:00:00', 'Entrevista agendada', 8, 'PENDENTE', 'ENTREVISTA'),
('2025-01-01 14:00:00', 'Visita confirmada', 9, 'PENDENTE', 'VISITA'),
('2025-02-01 15:00:00', 'Contrato preparado', 10, 'PENDENTE', 'CONTRATO'),
('2025-03-01 16:00:00', 'Finalização', 11, 'CONCLUIDA', 'FINALIZACAO'),
('2025-04-01 17:00:00', 'Acompanhamento pós', 12, 'PENDENTE', 'ACOMPANHAMENTO'),
('2025-05-01 18:00:00', 'Encerramento', 13, 'CONCLUIDA', 'ENCERRAMENTO'),
('2025-06-01 19:00:00', 'Feedback coletado', 14, 'CONCLUIDA', 'FEEDBACK'),
('2025-07-01 20:00:00', 'Nova solicitação', 15, 'PENDENTE', 'SOLICITACAO'),
('2025-08-01 21:00:00', 'Avaliação inicial', 16, 'PENDENTE', 'AVALIACAO'),
('2025-09-01 22:00:00', 'Documentação revisada', 17, 'PENDENTE', 'DOCUMENTACAO'),
('2025-10-01 23:00:00', 'Aprovação final', 18, 'CONCLUIDA', 'APROVACAO'),
('2025-11-01 00:00:00', 'Conclusão do processo', 19, 'CONCLUIDA', 'CONCLUSAO');

-- Mensagens
INSERT INTO Mensagem (dataMensagem, conteudo, idRemetente, tipoRemetente, idDestinatario, tipoDestinatario, id_processo) VALUES
('2023-01-01 14:00:00', 'Olá, interessado no Rex', 1, 'adotante', 1, 'protetor', 1),
('2023-02-01 15:00:00', 'Quando posso visitar?', 2, 'adotante', 2, 'protetor', 2),
('2023-03-01 16:00:00', 'Tudo certo para adoção', 3, 'protetor', 3, 'adotante', 3),
('2023-04-01 17:00:00', 'Informações sobre o animal', 4, 'protetor', 4, 'adotante', 4),
('2023-05-01 18:00:00', 'Agendamento confirmado', 5, 'adotante', 5, 'protetor', 5),
('2023-06-01 19:00:00', 'Dúvidas sobre adoção', 6, 'adotante', 6, 'protetor', 6),
('2023-07-01 20:00:00', 'Resposta às dúvidas', 7, 'protetor', 7, 'adotante', 7),
('2023-08-01 21:00:00', 'Atualização de status', 8, 'protetor', 8, 'adotante', 8),
('2023-09-01 22:00:00', 'Confirmação de visita', 9, 'adotante', 9, 'protetor', 9),
('2023-10-01 23:00:00', 'Preparativos para adoção', 10, 'protetor', 10, 'adotante', 10),
('2023-11-01 00:00:00', 'Pergunta sobre cuidados', 11, 'adotante', 11, 'protetor', 11),
('2023-12-01 01:00:00', 'Orientações fornecidas', 12, 'protetor', 12, 'adotante', 12),
('2024-01-01 02:00:00', 'Feedback positivo', 13, 'adotante', 13, 'protetor', 13),
('2024-02-01 03:00:00', 'Agradecimento', 14, 'protetor', 14, 'adotante', 14),
('2024-03-01 04:00:00', 'Nova mensagem', 15, 'adotante', 15, 'protetor', 15),
('2024-04-01 05:00:00', 'Resposta rápida', 16, 'protetor', 16, 'adotante', 16),
('2024-05-01 06:00:00', 'Atualização', 17, 'adotante', 17, 'protetor', 17),
('2024-06-01 07:00:00', 'Confirmação', 18, 'protetor', 18, 'adotante', 18),
('2024-07-01 08:00:00', 'Pergunta adicional', 19, 'adotante', 19, 'protetor', 19),
('2024-08-01 09:00:00', 'Última resposta', 20, 'protetor', 20, 'adotante', 20);

-- Junção Processo e Mensagem
INSERT INTO Processo_Mensagem (id_processo, id_mensagem) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

-- Adoções
INSERT INTO Adocao (dataAdocao, descricao, termos, id_processo) VALUES
('2023-01-05 15:00:00', 'Adoção concluída', 'Termos aceitos', 1),
('2023-05-05 17:00:00', 'Adoção finalizada', 'Documentos assinados', 5),
('2023-06-05 19:00:00', 'Adoção bem-sucedida', 'Termos aceitos', 6),
('2023-07-05 20:00:00', 'Finalizada com sucesso', 'Documentos ok', 7),
('2023-08-05 21:00:00', 'Nova adoção', 'Tudo certo', 8),
('2023-09-05 22:00:00', 'Concluída', 'Assinado', 9),
('2023-10-05 23:00:00', 'Adoção realizada', 'Termos', 10),
('2023-11-05 00:00:00', 'Sucesso', 'Aceito', 11),
('2023-12-05 01:00:00', 'Final', 'Ok', 12),
('2024-01-05 02:00:00', 'Concluída', 'Assinado', 13),
('2024-02-05 03:00:00', 'Adoção', 'Termos', 14),
('2024-03-05 04:00:00', 'Sucesso', 'Ok', 15),
('2024-04-05 05:00:00', 'Finalizada', 'Aceito', 16),
('2024-05-05 06:00:00', 'Concluída', 'Assinado', 17),
('2024-06-05 07:00:00', 'Adoção', 'Termos', 18),
('2024-07-05 08:00:00', 'Sucesso', 'Ok', 19),
('2024-08-05 09:00:00', 'Final', 'Aceito', 20),
('2024-10-05 11:00:00', 'Adoção', 'Termos', 2),
('2024-11-05 12:00:00', 'Sucesso', 'Ok', 3);

select * from adocao;

-- Suportes Pós-Adoção
INSERT INTO SuportePosAdocao (dataRegistro, tipoSolicitacao, descricao, idAdocao) VALUES
('2023-01-10 16:00:00', 'Consulta veterinária', 'Ajuda com vacinas', 1),
('2023-05-10 18:00:00', 'Acompanhamento', 'Verificação de adaptação', 2),
('2023-06-10 19:00:00', 'Consulta veterinária', 'Vacinas extras', 3),
('2023-07-10 20:00:00', 'Acompanhamento', 'Adaptação', 4),
('2023-08-10 21:00:00', 'Dúvidas', 'Cuidados diários', 5),
('2023-09-10 22:00:00', 'Consulta', 'Saúde', 6),
('2023-10-10 23:00:00', 'Suporte', 'Alimentação', 7),
('2023-11-10 00:00:00', 'Acompanhamento', 'Comportamento', 8),
('2023-12-10 01:00:00', 'Consulta', 'Vacinas', 9),
('2024-01-10 02:00:00', 'Dúvidas', 'Treinamento', 10),
('2024-02-10 03:00:00', 'Suporte', 'Saúde mental', 11),
('2024-03-10 04:00:00', 'Acompanhamento', 'Adaptação', 12),
('2024-04-10 05:00:00', 'Consulta', 'Exames', 13),
('2024-05-10 06:00:00', 'Dúvidas', 'Cuidados', 14),
('2024-06-10 07:00:00', 'Suporte', 'Alimentação', 15),
('2024-07-10 08:00:00', 'Acompanhamento', 'Comportamento', 16),
('2024-08-10 09:00:00', 'Consulta', 'Vacinas', 17),
('2024-09-10 10:00:00', 'Dúvidas', 'Treinamento', 18),
('2024-10-10 11:00:00', 'Suporte', 'Saúde', 19),
('2024-11-10 12:00:00', 'Acompanhamento', 'Adaptação', 20);
