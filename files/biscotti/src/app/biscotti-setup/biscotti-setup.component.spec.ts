import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BiscottiSetupComponent } from './biscotti-setup.component';

describe('BiscottiSetupComponent', () => {
  let component: BiscottiSetupComponent;
  let fixture: ComponentFixture<BiscottiSetupComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BiscottiSetupComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BiscottiSetupComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
