#!/usr/bin/env python
# coding: utf-8

# In[50]:


from langchain.chains import RetrievalQA
from langchain.llms import OpenAI
from langchain.document_loaders import PyPDFLoader
from langchain.indexes import VectorstoreIndexCreator
import glob
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.indexes.vectorstore import VectorStoreIndexWrapper
from langchain.text_splitter import CharacterTextSplitter
from langchain.chat_models import ChatOpenAI
import os
from PyPDF2 import PdfReader
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.text_splitter import TokenTextSplitter
from langchain.vectorstores import Chroma
from langchain.document_loaders import TextLoader
from langchain.prompts import PromptTemplate
from langchain.chains.qa_with_sources import load_qa_with_sources_chain

get_ipython().run_line_magic('env', 'OPENAI_API_KEY=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')


# In[2]:


document_index = None
persist_directory = "/Users/juan/Documents/Econ_unidos"
pdf_folder="/Users/juan/Documents/Juan MacBook Pro/CUNEF/Quinto/TFM/Selectividad/Economia Unidos"


# In[32]:


def init_document_index_old():
    global document_index 
    if document_index is None:
        print('\nInitializing Document Index')
        files = glob.glob(pdf_folder+'/*.pdf', recursive=False)
        documents = [PyPDFLoader(f).load() for f in files]
        documents = [item for sublist in documents for item in sublist]
        embedding = OpenAIEmbeddings() # type: ignore
        text_splitter = CharacterTextSplitter(
            chunk_size=800,
            chunk_overlap=10,
            length_function=len) # A mirar entre pregunta
        docs = text_splitter.split_documents(documents) # type: ignore
        print('\nLoading to Chroma')
        vectordb = Chroma.from_documents(documents=docs, embedding=embedding, persist_directory=persist_directory)
        print('\nPersisting')
        vectordb.persist()
        print('\nPersisted')
        document_index = VectorStoreIndexWrapper(vectorstore=vectordb)
    return document_index


# In[36]:


def init_document_index():
    global document_index 
    if document_index is None:
        print('\nInitializing Document Index')
        files = glob.glob(pdf_folder+'/*.pdf', recursive=False)
        text = ''
        for file in files:
            PyPDF2.PdfReader(file)
            for page_num in range(len(reader.pages)):
                page = pdf_reader.pages[page_num]
                text += page.extract_text() # type: ignore
        docs = re.split(r"\d\.\s", text)
        embedding = OpenAIEmbeddings()
        print('\nLoading to Chroma')
        vectordb = Chroma.from_texts(texts=docs, embedding=embedding, persist_directory=persist_directory)
        print('\nPersisting')
        vectordb.persist()
        print('\nPersisted')
        document_index = VectorStoreIndexWrapper(vectorstore=vectordb)
    return document_index


# In[39]:


def get_document_index():
    global document_index
    if document_index is None:
        print()
        embedding = OpenAIEmbeddings() # type: ignore
        vectordb = Chroma(persist_directory=persist_directory, embedding_function=embedding)
        document_index = VectorStoreIndexWrapper(vectorstore=vectordb)
    return document_index


# In[40]:


def get_document_vectordb():
    embedding = OpenAIEmbeddings() # type: ignore
    vectordb = Chroma(persist_directory=persist_directory, embedding_function=embedding)
    return vectordb


# In[41]:


gpt4 = ChatOpenAI(model_name="gpt-4", temperature=0) # type: ignore


# In[37]:


# init_document_index()


# In[42]:


index=get_document_index()


# In[84]:


template = """Use the following pieces of context to answer the question at the end. 
In the context you will find a statement part which is the exam question, and a solution part which is the text between "SOLUCIÓN:" and the next question statement.
You should only show the solution part if requested by the prompt.
If you are asked to provide questions, print the question literally without changing the wording.

Alternatively you may be asked to give feedback on an answer to a given question.
In this case find the question being asked and compare the user respones to the solution part (text after "SOLUCION:")and correct whatever is wrong or incomplete.
Give a score out of ten to the user solution.


If you don't know the answer, just say that you don't know. Don't try to make up an answer.
Respond in Spanish.


{context}

QUESTION: {question}
=========
FINAL ANSWER IN SPANISH:"""
PROMPT = PromptTemplate(template=template, input_variables=["context", "question"])


# In[85]:


chain_type_kwargs = {"prompt": PROMPT}
qa = RetrievalQA.from_chain_type(gpt4, chain_type="stuff",
                                 retriever=get_document_vectordb().as_retriever(),
                                 chain_type_kwargs=chain_type_kwargs, verbose = True)


# In[78]:


query = "Dame dos preguntas"
print(qa.run(query))


# In[79]:


query = "Dame dos preguntas y sus respuestas"
print(qa.run(query))


# In[87]:


query = """ 
Estoy respondiendo a la pregunta:Señale a qué tipo de organización de la empresa, formal o informal, responde la siguiente situación, argumentando su respuesta: «La persona que se incorporó a comienzos de año al departamento de expansión tiene una especial habilidad para trasmitir entusiasmo y motivación, creando un excelente ambiente de trabajo, colaboración y camaradería entre la mayor parte de la plantilla»
Y mi respuesta es:
Es una organizacion formal porque surgio espontaneamente. ademas las relaciones se gestan voluntariamente
"""
print(qa.run(query))


# In[88]:


query = """ 
Hazme una pregunta sobre el punto muerto pero cambia los datos y dame la respuesta ajustada a los nuevos datos 
"""
print(qa.run(query))


# In[ ]:




