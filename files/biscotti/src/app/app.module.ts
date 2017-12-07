import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

// Material modules
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatSnackBarModule } from '@angular/material/snack-bar';


// Custom Validators
import { EqualToValidator } from './equal-to-validator.directive';

// App components
import { AppComponent } from './app.component';
import { BiscottiConfigService } from './biscotti-config.service';
import { BiscottiAuthService } from './biscotti-auth.service';
import { StarterKitService } from './starter-kit.service';
import { BiscottiSetupComponent } from './biscotti-setup/biscotti-setup.component';
import { BiscottiAuthComponent } from './biscotti-auth/biscotti-auth.component';

@NgModule({
  declarations: [
    EqualToValidator,
    AppComponent,
    BiscottiAuthComponent,
    BiscottiSetupComponent,
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    HttpClientModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatGridListModule,
    MatProgressSpinnerModule,
    MatSlideToggleModule,
    MatSnackBarModule
  ],
  providers: [
    BiscottiAuthService,
    BiscottiConfigService,
    StarterKitService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
