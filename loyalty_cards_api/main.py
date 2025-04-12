import os
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from dotenv import load_dotenv

# Load environment variables from a .env file (if you are using one)
load_dotenv()

# FastAPI app setup
app = FastAPI()

# Get values from environment variables or use default values
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./loyalty.db")
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", 8000))

# SQLAlchemy setup
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# SQLAlchemy model
class LoyaltyCard(Base):
    __tablename__ = "loyalty_cards"
    id = Column(Integer, primary_key=True, index=True)
    issuer = Column(String)
    client = Column(String)
    tokens = Column(Integer)

# Create tables
Base.metadata.create_all(bind=engine)

# Pydantic models
class LoyaltyCardCreate(BaseModel):
    issuer: str
    client: str
    tokens: int

class LoyaltyCardResponse(BaseModel):
    id: int
    issuer: str
    client: str
    tokens: int

    class Config:
        orm_mode = True

# Dependency for getting DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Routes
@app.post("/cards/", response_model=dict)
def create_card(card: LoyaltyCardCreate, db: Session = Depends(get_db)):
    db_card = LoyaltyCard(**card.dict())
    db.add(db_card)
    db.commit()
    db.refresh(db_card)
    return {"id": db_card.id}

@app.get("/cards/", response_model=List[LoyaltyCardResponse])
def read_cards(db: Session = Depends(get_db)):
    return db.query(LoyaltyCard).all()

@app.put("/cards/{card_id}", response_model=dict)
def update_card(card_id: int, card: LoyaltyCardCreate, db: Session = Depends(get_db)):
    db_card = db.query(LoyaltyCard).filter(LoyaltyCard.id == card_id).first()
    if not db_card:
        raise HTTPException(status_code=404, detail="Card not found")
    for field, value in card.dict().items():
        setattr(db_card, field, value)
    db.commit()
    return {"msg": "updated"}

@app.delete("/cards/{card_id}", response_model=dict)
def delete_card(card_id: int, db: Session = Depends(get_db)):
    db_card = db.query(LoyaltyCard).filter(LoyaltyCard.id == card_id).first()
    if not db_card:
        raise HTTPException(status_code=404, detail="Card not found")
    db.delete(db_card)
    db.commit()
    return {"msg": "deleted"}

# Running the app with environment variables (for example, via `uvicorn`):
# uvicorn main:app --host $HOST --port $PORT
