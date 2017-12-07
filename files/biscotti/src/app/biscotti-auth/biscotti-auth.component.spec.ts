import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BiscottiAuthComponent } from './biscotti-auth.component';

describe('BiscottiAuthComponent', () => {
  let component: BiscottiAuthComponent;
  let fixture: ComponentFixture<BiscottiAuthComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BiscottiAuthComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BiscottiAuthComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
